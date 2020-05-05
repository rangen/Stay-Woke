module Slug
    def build_out_params(args)
        args.each_pair {|k, v| slug += "&#{k}=#{v}"}
        encode(slug)
    end

    def encode(str)
        str.gsub(" ", "%20")
    end
end