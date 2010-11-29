# encoding: utf-8

module Fjomp
  module Attachment
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def acts_as_attachment(*args)
        options = args.extract_options!
        send :include, InstanceMethods

        after_create :move_uploaded_file_to_final_path
      end
    end

    module InstanceMethods
      # After a file has been uploaded, call this method on a new
      # Attachment-instance with the file field as parameter. The
      # "after_save" method will care for copying the file from its
      # temporary location
      def file=(file_data)
        @temporary_file = file_data
        self.filename = base_part_of(file_data.original_filename)
        self.content_type = file_data.content_type.strip
      end

      # After an attachment has been stored in the database, copy the
      # file from the temporary upload location to its final directory
      def move_uploaded_file_to_final_path
        FileUtils.mkpath(base_directory)

        File.open(path, "wb") do |f|
          @temporary_file.rewind
          f.write(@temporary_file.read)
        end
      end

      def url
        "#{base_url}/#{filename}"
      end

      def path
        File.join(base_directory, filename)
      end

      def size
        File.size(path)
      end

      def base_part_of(filename)
        b = File.basename(filename.strip)
        b.gsub(%r{^\.|[\s/\\\*\:\?'"<>\|]}, '_')
      end
    end
  end

  ActiveRecord::Base.send :include, Attachment
end


     


