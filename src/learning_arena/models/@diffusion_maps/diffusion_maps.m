classdef diffusion_maps < manifold_learning
    %DIFFUSION_MAPS Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function obj = diffusion_maps(varargin)
            %DIFFUSION_MAPS Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@manifold_learning(varargin{:});
            if ~isfield(obj.params_, 'alpha'); obj.params_.alpha = 0; end
            if  ~isfield(obj.params_, 'kernel')
                obj.params_.kernel = rbf; 
                obj.params_.kernel.set_params('sigma', 5.);
                obj.params_.epsilon = 2*obj.params_.kernel.params('sigma').^2;
            end
            if ~isfield(obj.params_, 'operator'); obj.params_.operator = 'transport'; end
        end
        
        function T = transport(obj)
            if ~obj.is_transport_
                S = obj.similarity;
                D = obj.degree(S);

                switch obj.params_.alpha
                    case 0 
                        obj.transport_ = D\S;
                    case 1
                        obj.transport_ = D\S/D;
                        obj.transport_ = obj.degree(obj.transport_)\obj.transport_;
                    otherwise
                        obj.transport_ = D^-obj.params_.alpha*S*D^-obj.params_.alpha;
                        obj.transport_ = obj.degree(obj.transport_)\obj.transport_;
                end
                obj.is_transport_ = true;
            end
            
            if nargout > 0; T = obj.transport_; end
        end
        
        function L = infinitesimal(obj)
            if ~obj.is_infinitesimal_
                obj.infinitesimal_ = (speye(obj.m_) - obj.transport)/obj.params_.epsilon;
                obj.is_infinitesimal_ = true;
            end
            
            if nargout > 0; L = obj.infinitesimal_; end
        end
    end
    
    methods (Access = protected)
        function signature(obj)            
            obj.params_name_ = ['kernel', 'alpha', 'epsilon', 'operator', obj.params_name_];
            obj.type_ = {'graph-less'};
        end
        
        function reset(obj)
           reset@manifold_learning(obj);
           
           obj.is_transport_ = false;
           obj.is_infinitesimal_ = false;
        end
        
        function [V,D,W] = solve(obj)      
            switch obj.params_.operator
                case 'transport'
                    % Sparse matrix solution
                    [V,D] = eigs(obj.transport, obj.params_.num_eigs, 'largestabs', 'Tolerance',1e-10, 'MaxIterations', 5000);
                    [W,~] = eigs(obj.transport', obj.params_.num_eigs, 'largestabs', 'Tolerance',1e-10, 'MaxIterations', 5000);
                    
                    % Full matrix solution
                    % [V,D,W] = eig(full(obj.transport));
                    % [a, b] = sort(diag(D),'descend');
                    % D = diag(a);
                    % V = V(:,b);
                    % W = W(:,b);
                case 'infinitesimal'
                    [V,D] = eigs(obj.transport, obj.params_.num_eigs, 'smallestabs');
                    [W,~] = eigs(obj.transport', obj.params_.num_eigs, 'smallestabs');

                    % Full matrix solution
                    % [V,D,W] = eig(full(obj.transport));
                    % [a, b] = sort(diag(D),'ascend');
                    % D = diag(a);
                    % V = V(:,b);
                    % W = W(:,b);
                otherwise
                    error('Case not found')
            end
        end
    end
    
    properties (Access = protected)
        transport_
        infinitesimal_
        
        is_transport_
        is_infinitesimal_
    end
end

