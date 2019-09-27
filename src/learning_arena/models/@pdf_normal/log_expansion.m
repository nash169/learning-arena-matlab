function log_psi = log_expansion(obj, data)
obj.check;
if nargin > 1; obj.set_data(data); end
obj.input;

if ~obj.is_log_psi_
    switch obj.type_cov_
       case 1
           logdet = prod(obj.cov_.*ones(1,obj.d_));
       case 2
           logdet = 2*sum(log(diag(obj.cov_)));
       otherwise
           error('Case not present'); 
    end
    
    obj.log_psi_ = -obj.d_*log(2*pi)/2 - logdet/2 + obj.h_params_.kernel.log_kernel(obj.input_{:});
    obj.is_log_psi_ = true;
end

if nargout > 0; log_psi = obj.log_psi_; end
end
