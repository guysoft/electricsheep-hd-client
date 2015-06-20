#!/usr/bin/env ruby
sleep 2
require 'fileutils'
require 'tempfile'
require 'pathname'
require 'optparse'
require 'uri'
require 'net/http'
require 'net/https'
require 'net/http/post/multipart'
require 'openssl'
require 'zlib'
require 'json'
@options={}
OptionParser.new do |opts|
  opts.banner = "Usage: daemon.rb [@options]"
  opts.on("--server SERVER", "Control server to connect to") {|v| @options["server"] = v.to_s}
  opts.on("--apikey APIKEY", "Your api key") {|v| @options["apikey"] = v}
  opts.on("--debug", "Debug") {|v| @options["debug"] = true}
  opts.on("-hHEIGHT", "--height=HEIGHT", "HEIGHT of rendered frames") {|h| @options[:h] = h.to_i}
  opts.on("-qQUALITY", "--quality=QUALITY", "QUALITY of rendered frames") {|q| @options[:q] = q.to_i}
end.parse!


file_abosulte = File.expand_path(__FILE__)
@basedir = Pathname.new(file_abosulte).dirname

@options["server"] ||= "https://triple6.org:9999"
raise "You will need a api key. Please register at #{@options["server"]}/register" if @options["apikey"].nil? && !File.exist?("#{@basedir}/api.key")
@options["apikey"] ||= File.read("#{@basedir}/api.key").strip
@options["debug"] ||= false
$DEBUG = @options["debug"]


@anim_template = ""
NICE=10


class API
  attr_reader :http
  def initialize(options={})
    @server = options[:server]
    @uri = URI.parse(@server)
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def get(url)
    uri = @uri + url
    request = Net::HTTP::Get.new(uri.request_uri)
    response = @http.request(request)
    response
  end
end

@api = API.new({server: @options["server"]})

def request_work
  begin
    response = @api.get("api/request_work?apikey=#{@options["apikey"]}")
    raise "Error in work request: #{response.body}" if response.code != "200"
    work = JSON.parse(response.body)
  rescue NilClass => e
    print "Error: #{e}"
    sleep 10
    return
  end
  work.each do |w|
    genome_file = "#{@animated_genome_dir}/#{w['sequence']}.flame"
    unless File.exist?(genome_file)
      begin
        gid1 = w['sequence'].split("_")[0]
        gid2 = w['sequence'].split("_")[1]
        puts "Downloading #{gid1}..."
        genome1 = download_genome(gid1)
        unless gid1 == gid2
          puts "Downloading #{gid2}..."
          genome2 = download_genome(gid2)
        else
          genome2 = genome1.dup
        end
        puts "Animating..."
        animate_genome(genome1, genome2)
      rescue NilClass => e
        puts e
        sleep 10
        return
      end
    end
    puts "Rendering... #{w['sequence']} Frame #{w['frame']}"
    frame = render_frame(genome_file, w["frame"])
    puts "Uploading... #{w['sequence']} Frame #{w['frame']}"
    begin
      upload_frame(frame, w)
    rescue NilClass => e
      puts e
      sleep 10
      return
      end
  end
end

def download_genome(gid)
  output_file = "#{@genome_dir}/#{gid}.flam3"
  response = @api.get("genomes/#{gid}.flam3.gz")
  raise "Error in download: #{response.body}" if response.code != "200"
  File.open("#{@genome_dir}/#{gid}.flam3.gz", "w") { |f| f.write(response.body) }
  Zlib::GzipReader.open("#{@genome_dir}/#{gid}.flam3.gz") do |gz|
    File.open(output_file, "w") do |g|
      IO.copy_stream(gz, g)
    end
  end
  File.delete("#{@genome_dir}/#{gid}.flam3.gz")
  output_file
end


def animate_genome(genome1, genome2)
  gid1  = (File.basename(genome1).split(".") - genome1.split(".").last(1)).join(".")
  gid2  = (File.basename(genome2).split(".") - genome2.split(".").last(1)).join(".")
  # Merge old and new flames into a single file to make the animation from

  temp_genome = Tempfile.new("electricsheep-hd")
  temp_genome.write "<flames name=\"Batch\">\n"
  temp_genome.write File.read(genome1)
  temp_genome.write File.read(genome2)
  temp_genome.write "</flames>\n"
  temp_genome.rewind
  temp_genome.fsync

  # Creates a new flame file with enough frames to loop
  ENV["template"] = File.expand_path(@anim_template)
  ENV["sequence"] = File.expand_path(temp_genome)
  ENV["nframes"] = @season[:nframes]
  `flam3-genome > #{@animated_genome_dir}/#{gid1}_#{gid2}.flame`

end
def render_frame(genome_file, frame)
  genome = {}
  genome["file"] = Pathname.new(genome_file.to_s)
  genome["id"] = genome["file"].basename.sub(/\.flame$/,"")

  concat_name = "#{genome['id']}"
  start_frame = frame
  Dir.mkdir("#{@frame_dir}/#{concat_name}") unless File.exist?("#{@frame_dir}/#{concat_name}")
  end_frame = start_frame
  #ENV["in"] = File.expand_path("animated_genomes/#{genome[:id]}_#{genome[:id]}.flame")
  ENV["template"] = File.expand_path(@anim_template)
  ENV["in"] = File.expand_path(genome_file)
  ENV["prefix"]= "#{@frame_dir}/#{concat_name}/"
  ENV["format"] = "jpg"
  ENV["jpeg"] = 95.to_s
  ENV["begin"] = start_frame.to_s
  ENV["end"] = end_frame.to_s
  `nice -#{NICE} flam3-animate`
  leeding_zeros = "0" * ( 5 - start_frame.to_s.length)
  return "#{@frame_dir}/#{concat_name}/#{leeding_zeros}#{start_frame}.jpg"
end

def upload_frame(frame_file, work_set)
  url = URI.parse(@options["server"] + "/api/upload")
  File.open(frame_file) do |jpg|
    req = Net::HTTP::Post::Multipart.new(url.path,
                                         "file" => UploadIO.new(jpg, "image/jpeg", "image.jpg"),
                                         "apikey" => @options["apikey"],
                                         "work_set" => work_set.to_json,
                                         "branch" => @branch)
    response = @api.http.request(req)
    raise "Error in upload: #{response.body}" if response.code != "200"
  end
end

loop do
  begin
    response = @api.get("api/active_season?apikey=#{@options["apikey"]}")
    raise "Error in season: #{response.body}" if response.code != "200"
    @season = JSON.parse(response.body)

    File.delete(@anim_template) if File.exist?(@anim_template)
    @anim_template = File.open("anim_template.flame", "w+")
    @anim_template.write "<flame temporal_samples=\"200\" quality=\"#{@season['quality']}\" size=\"#{@season['width']} #{@season['height']}\" />\n"
    @anim_template.fsync
  rescue NilClass => e
    puts e
    sleep 10
    next
  end

  @branch = @season["name"]
  @branch_dir = "#{@basedir}/branches/#{@branch}"
  @genome_dir = "#{@branch_dir}/genomes"
  @animated_genome_dir = "#{@branch_dir}/animated_genomes"
  @frame_dir = "#{@branch_dir}/frames"
  @movie_dir = "#{@branch_dir}/movies"

  FileUtils.mkdir_p(@genome_dir)
  FileUtils.mkdir_p(@animated_genome_dir)
  FileUtils.mkdir_p(@frame_dir)
  FileUtils.mkdir_p(@movie_dir)

  puts "Requesting new work..."
  request_work
end
