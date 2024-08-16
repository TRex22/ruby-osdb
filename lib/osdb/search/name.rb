module OSDb
  module Search
    class Name
      require 'amatch'
      include Amatch

      # TODO: Make this an option
      MINIMUM_MATCH_PERCENTAGE = 0.70

      def initialize(server)
        @server = server
      end

      def search_subs_for(movie, language)
        subs = @server.search_subtitles(:sublanguageid => language, :query => movie.name)
        normalized_movie_name = normalize_name(movie.name)

        selected_subs = subs.select do |sub|
          normalized_filename = normalize_name(sub.filename)
          normalized_filename.index(normalized_movie_name)
        end

        if selected_subs.nil? || selected_subs == []
          # If indexing does not match take the closest one
          selected_subs = subs.select do |sub|
            normalized_filename = normalize_name(sub.filename)
            match_via_jaro_winkler(normalized_filename, normalized_movie_name) >= MINIMUM_MATCH_PERCENTAGE
          end
        end

        selected_subs
      end

      protected

      def normalize_name(name)
        name.downcase.gsub(/[\s\.\-\_]+/, ' ')
      end

      def match_via_jaro_winkler(filename, movie_name)
        m = Jaro.new(filename)
        m.ignore_case = true

        m.match(movie_name)
      end
    end
  end
end
