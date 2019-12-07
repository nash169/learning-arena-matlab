classdef k_means < handle
    %K_MEANS Summary of this class goes here
    %   Detailed explanation goes here

%=== PUBLIC ===%
    properties
        params_list_
    end
    
    methods
        function obj = k_means(varargin)
            %K_MEANS Construct an instance of this class
            %   Detailed explanation goes here
            obj.init;
            if nargin > 0; obj.set_params(varargin{:}); end
            
            if ~isfield(obj.params_, 'step'); obj.params_.step = 10; end
            if ~isfield(obj.params_, 'norm'); obj.params_.norm = 2; end
            if ~isfield(obj.params_, 'soft'); obj.params_.soft = false; end
            
            % Set a defaul kernel for soft k-means
            if ~isfield(obj.params_, 'kernel')
                obj.params_.kernel = rbf('sigma', 5.); 
            end
            
            obj.is_data_ = false;
            obj.is_params_ = false;
            obj.is_centroids_ = false;
            obj.reset;
        end
        
        set_params(obj, varargin)
        
        set_data(obj, data)
        
        params = params(obj, parameter)
        
        data = data(obj)
        
        [labels, centroids] = cluster(obj, data)
        
        fig = plot_data(obj, data, fig)
    end
    
%=== PROTECTED ===%
    properties (Access = protected)
        % Data and parameters
        data_
        
        m_
        
        d_
        
        params_
        
        % Centroids and labelling cluster
        centroids_
        
        labels_
        
        % Bool variables
        is_data_
        
        is_params_
        
        is_centroids_
        
        is_clustered_
    end
    
    methods (Access = protected)
        init(obj);
        
        check(obj)
        
        reset(obj)
    end
end

