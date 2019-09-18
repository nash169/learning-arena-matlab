classdef rbf_old < abstract_kernel
   methods
       function obj = rbf_old(varargin)
           obj = obj@abstract_kernel(varargin{:});
       end
       
       function k = get_kernel(obj, varargin)
           
           get_kernel@abstract_kernel(obj,varargin{:});
           
           if ~obj.kernel_
               obj.k_ = exp(obj.params_.length*vecnorm(obj.Args_{1}-obj.Args_{2},2,2).^2);
               obj.kernel_ = true;
           end
           
           k = obj.k_;
       end
       
       function dk = get_gradient(obj, var, varargin)

           get_gradient@abstract_kernel(obj,varargin{:});
           
           switch var
               case 1
                   if ~obj.gradient_{var}
                       obj.dk_{var} = 2*obj.params_.length*(obj.Args_{1}-obj.Args_{2}).*obj.get_kernel;
                       obj.gradient_{var} = true;
                   end
               case 2
                   if ~obj.gradient_{var}
                       obj.dk_{var} = -2*obj.params_.length*(obj.Args_{1}-obj.Args_{2}).*obj.get_kernel;
                       obj.gradient_{var} = true;
                   end
                   
               otherwise
                   error('Index incorrect.');
           end 
           
           dk = obj.dk_{var};
       end
       
       function d2k = get_hessian(obj, var, varargin)
           get_hessian@abstract_kernel(obj,varargin{:});
           
           switch var
               case 1
                   
               case 2
                   
               case 3
                   
               case 4
                   
               otherwise
                  error('Index incorrect.');
           end
           
           d2k = obj.d2k_{var};
       end
       
   end
   
   properties
      params_name_ = {'length'} 
      kernel_ = false;
      gradient_ = {false, false};
      hessian_ = {false, false, false, false};
      gramian_ = false;
   end
end

