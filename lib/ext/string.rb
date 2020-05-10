class String
    def build_params(args)
        str = self
        args.each_pair {|k, v| str += "&#{k}=#{v}" if v}  #don't build nil values into slug
        binding.pry
        self.encode_via_uri
    end

    def encode_via_uri
        URI.escape(self)
    end

    def scrub_name
        self.split.select{|s| !s.include?(".")}.join(" ")   #old way to delete name portions with periods.
    end
end