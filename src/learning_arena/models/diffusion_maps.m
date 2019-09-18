classdef diffusion_maps < manifold_learning
    %DIFFUSION_MAPS Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function obj = diffusion_maps(varargin)
            %DIFFUSION_MAPS Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@manifold_learning(varargin{:});
            if ~isfield(obj.params_, 'alpha'); obj.params_.sigma_f = 0; end
            if  ~isfield(obj.params_, 'kernel')
                obj.params_.kernel = rbf; 
                obj.params_.kernel.set_params('sigma', 5.);
            end
        end
        
        function M = transport(obj)
            if ~obj.is_transport_
                S = obj.similarity;
                D = obj.degree(S);
                M = D^-alpha*S*D^-alpha;
                obj.transport_ = obj.degree(M)\M;
                obj.is_transport_ = true;
            end
            
            if nargout > 0; M = obj.transport_; end
        end
        
        function L = inifinitesimal(obj)
            if ~obj.is_infinitesimal_
                obj.infinitesimal_ = (eye(obj.m_) - obj.transport)/obj.epsilon_;
                obj.is_infinitesimal_ = true;
            end
            
            if nargout > 0; L = obj.infinitesimal_; end
        end
    end
    
    methods (Access = protected)
        function signature(obj)            
            obj.params_name_ = {'kernel', 'alpha', 'epsilon'};
            obj.type_ = {'graph-less'};
        end
        
        function check(obj)
           check@manifold_learning(obj);
           
           if ~obj.is_epsilon_
               obj.epsilon_ = obj.params_.kernel.params('sigma');
               obj.is_epsilon_ = true;
           end
        end
        
        function reset(obj)
           reset@manifold_learnig(obj);
           
           obj.is_transport_ = false;
           obj.is_infinitesimal_ = false;
           obj.is_epsilon_ = false;
        end
        
        function [V,D,W] = solve(obj, type)
            if nargin < 2; type = 'transport'; end
            
            switch type
                case 'transport'
                    [V,D,W] = eig(obj.transport);
                    [a, b] = sort(diag(D),'descend');
                    D = diag(a);
                    V = V(:,b);
                    W = W(:,b);       
                case 'infinitesimal'
                    [V,D,W] = eig(obj.infinitesimal);
                    [a, b] = sort(diag(D),'ascend');
                    D = diag(a);
                    V = V(:,b);
                    W = W(:,b); 
                otherwise
                    error('Case not found')
            end
        end
    end
    
    properties (Access = protected)
        transport_
        infinitesimal_
        epsilon_
        
        is_transport_
        is_infinitesimal_
        is_epsilon_
    end
end

