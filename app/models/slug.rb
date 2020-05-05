module Slug
    def self.build_params(args)
        str = ""
        args.each_pair {|k, v| str += "&#{k}=#{v}"}
        puts str
        encode(str)
    end

    def self.encode(str)
        str.gsub(" ", "%20")
    end
end