function phi = embedding(obj,varargin)
%EMBEDDING Summary of this function goes here
%   Detailed explanation goes here
if nargin > 1; obj.set_data(varargin{:}); end
obj.check;

if ~obj.is_embedding_
    obj.phi_ = obj.calc_embedding;
    obj.is_embedding_ = true;
end

if nargout > 0; phi = obj.phi_; end
end

