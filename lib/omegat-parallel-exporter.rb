require 'pp'
require 'fileutils'

class OmegatParallelExporter
  SOURCE_DIR = "/source"
  TARGET_DIR = "/target"
  PARALLEL_DIR = "/parallel"
  
  def initialize(project_dir, ext, separator)
    @project_dir = project_dir
    @extention = ext
    @separator = separator
    @source_files = list SOURCE_DIR
    @target_files = list TARGET_DIR

    validate

    @fileset = @source_files.zip(@target_files)
  end

  def export_files
    FileUtils.mkdir(@project_dir + PARALLEL_DIR) unless File.exists?(@project_dir + PARALLEL_DIR)
    
    @fileset.each do |source, target|
      exports_file(source, target)
    end    
  end

  def say_hello
    puts "It works!"
  end

  private
  def exports_file(source, target)
    raise if File.basename(source) != File.basename(target)
    source_paragraphs = File.open(source).readlines(@separator)
    target_paragraphs = File.open(target).readlines(@separator)

    raise if source_paragraphs.count != target_paragraphs.count
    paragraphs_set = source_paragraphs.zip(target_paragraphs)

    File.open(@project_dir + PARALLEL_DIR + "/" + File.basename(source), "w+") do |f|
      paragraphs_set.each do |source_paragraph, target_paragraph|
        f.write source_paragraph
        f.write target_paragraph unless source_paragraph == target_paragraph
      end
    end
  end

  def validate
    raise if @source_files.count != @target_files.count
  end
  
  def list(dir)
    target = @project_dir + dir + "/*.#{ @extention }"
    Dir.glob(target).sort
  end
end

main = OmegatParallelExporter.new(ARGV[0], "txt", "\n\n")
main.export_files
main.say_hello

