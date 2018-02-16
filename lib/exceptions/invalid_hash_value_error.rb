class InvalidHashValueError < StandardError
    def initialize(msg='Value must be a sha-256 hash string prefixed with "sha-256:"')
        super
    end
end