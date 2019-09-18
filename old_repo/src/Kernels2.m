function [f, varargout] = Kernels2(type, param)
%KERNELS Summary of this function goes here
%   Detailed explanation goes here

switch type      

    case 'gauss'
        [f, varargout{1}, varargout{2}] = rbf_test(param);
        
    case 'gauss_compact'
        [f, varargout{1}, varargout{2}] = rbf_compact(param);
        
    case 'gauss_vel'
        [f, varargout{1}, varargout{2}] = rbf_vel(param);
        
    case 'gauss_attracts'
        [f, varargout{1}, varargout{2}] = rbf_attracts(param);
        
    case 'gauss_hypervel'
        [f, varargout{1}, varargout{2}] = rbf_hypervel(param);

    case 'gauss_anisotr_vel'
        [f, varargout{1}, varargout{2}] = anisotropicRbf_vel(param);
        
    case 'gauss_anisotr_lyap'
        [f, varargout{1}] = anisotropicRbf_lyap(param);
        
    case 'gauss_anisotr_cov'
        [f] = anisotropicRbf_cov(param);
        
    case 'gauss_lyapunov'
        [f, varargout{1}] = rbf_lyapunov(param);
        
    case 'gauss_direct_grad'
        [f] = rbf_direct_grad(param);
        
    case 'gauss_direct_vel'
        [f] = rbf_direct_vel(param);

    case 'cosine'
        [f] = cosine;
    
    case 'cosine_cross'
        [f] = cosine_cross;
    
    case 'polynomial'
        [f] = polynomial(param);

    case 'euclid_dist'
        [f] = euclidian;
      
    case 'gauss_vv'
        [f] = VV_rbf(param);
       
    case 'curl_free'
        [f] = VV_curlFree(param);
        
    otherwise
        error('Kernel not available.');
end

end