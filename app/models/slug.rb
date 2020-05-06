class Slug
    def self.build_params(args)
        str = ""
        args.each_pair {|k, v| str += "&#{k}=#{v}"}
        encode(str)
    end

    def self.encode(str)
        str.gsub(" ", "%20")
    end

    def self.scrub_name(str)
        str.split.select{|s| !s.include?(".")}.join(" ")
    end
end