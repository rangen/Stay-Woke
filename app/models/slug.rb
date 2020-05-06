class Slug
    def self.build_params(args)
        str = ""
        args.each_pair {|k, v| str += "&#{k}=#{v}" if v}  #don't build nil values into slug
        encode(str)
    end

    def self.encode(str)
        str.gsub(" ", "%20")
    end

    def self.scrub_name(str)
        str.split.select{|s| !s.include?(".")}.join(" ")
    end
end