class Hash
    def build_params
        str = ""
        self.each_pair {|k, v| str += "&#{k}=#{v}" if v}  #don't build nil values into slug
        str.encode_via_uri
    end
end