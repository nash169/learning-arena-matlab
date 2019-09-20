classdef gauss_normal < handle
    %GAUSS_NORMAL Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = gauss_normal(varargin)
            %GAUSS_NORMAL Construct an instance of this class
            %   Detailed explanation goes here
            if nargin > 0
                obj.set_params(varargin{:});
            end
            obj.reset;
        end
        
        function set_params(obj, varargin)
            for i = 1 : 2 : length(varargin)
                assert(logical(sum(strcmp(obj.params_name_, varargin{i}))), '"%s" parameter not present', varargin{i})
                obj.params_.(varargin{i}) = varargin{i+1};
                if strcmp(varargin{i}, 'sigma')
                    obj.sigma_inv_ = inv(obj.params_.sigma);
                    obj.L_ = chol(obj.params_.sigma);
                end
            end
            obj.is_params_ = false;
            obj.reset;
        end
        
        function set_data(obj, data)
           obj.data_ = data;
           [obj.m_,obj.d_] = size(data);
           
           obj.is_data_ = true;
           obj.reset;
        end
        
        function set_grid(obj, res, varargin)
            d = length(varargin);
            grid = cell(1,d/2);
            counter = 1;
            
            for i = 1 : 2 : d
                grid{counter} = linspace(varargin{i}, varargin{i+1}, res);
                counter = counter + 1;
            end
            
            [obj.grid_{1:length(grid)}] =  ndgrid(grid{:});
            obj.grid_ = cellfun(@(x) permute(x, [2 1 3:ndims(x)]),obj.grid_, 'UniformOutput',false);
            obj.is_grid_ = true;
            
            obj.set_data(reshape([obj.grid_{:}], [], length(obj.grid_)));
            obj.reset;
        end
        
        % Get probability density distribution
        function pdf = pdf(obj, data)
            if nargin > 1
                nargin
                obj.set_data(data);
            end
            
            if ~obj.is_pdf_
                obj.check;
                obj.pdf_ = exp(-sum((obj.data_-obj.params_.mean).*(obj.sigma_inv_*(obj.data_-obj.params_.mean)')',2)/2) ...
                    /sqrt((2*pi)^obj.d_*det(obj.params_.sigma));
                obj.is_pdf_ = true;
            end
            
            pdf = obj.pdf_;
        end
        
        function dpdf = pdf_grad(obj, dev_type, data)
            if nargin < 2 
                dev_type = 'data';
            end
            
            if nargin > 2
                obj.set_data(data);
            end
            
            switch dev_type
                case 'data'
                    if ~isfield(obj.dpdf_, 'data')
                        obj.dpdf_.('data') = -(obj.sigma_inv_*(obj.data_-obj.params_.mean)')'.*obj.pdf;
                    end
                case 'mean'
                    if ~isfield(obj.dpdf_, 'mean')
                        obj.dpdf_.('mean') = (obj.sigma_inv_*(obj.data_-obj.params_.mean)')'.*obj.pdf;
                    end
                case 'sigma'
                    if ~isfield(obj.dpdf_, 'sigma')
                        obj.dpdf_.('sigma') = -(repmat(obj.sigma_inv_, obj.m_, 1) - ...
                        outer_product((obj.sigma_inv_*(obj.data_-obj.params_.mean)')', ...
                                      (obj.data_-obj.params_.mean)*obj.sigma_inv_))/2 ...
                                      .*repelem(obj.pdf, obj.d_,1);
                    end
                otherwise
                    error("Derivation not possible")        
            end
            
            dpdf = obj.dpdf_.(dev_type);
        end
        
        % Get log-probability density distribution
        function logpdf = logpdf(obj, data)
            if nargin > 1; obj.set_data(data); end
            
            if ~obj.is_logpdf_
                obj.check;
                obj.logpdf_ = -(2*sum(log(diag(obj.L_))) + ...
                    sum((obj.data_-obj.params_.mean).*(obj.sigma_inv_*(obj.data_-obj.params_.mean)')',2) + ...
                    obj.d_*log(2*pi))/2;
                obj.is_logpdf_ = true;
            end
            
            logpdf = obj.logpdf_;
        end
        
        function dlogpdf = logpdf_grad(obj, data, dev_type)
            if nargin < 2; dev_type = 'data'; end
            if nargin > 2; obj.set_data(data); end
            
            switch dev_type
                case 'data'
                    if ~isfield(obj.dlogpdf_, 'data')
                        obj.dlogpdf_.data = -(obj.sigma_inv_*(obj.data_-obj.params_.mean)')';
                    end
                case 'mean'
                    if ~isfield(obj.dlogpdf_, 'mean')
                        obj.dlogpdf_.mean = (obj.sigma_inv_*(obj.data_-obj.params_.mean)')';
                    end
                case 'sigma'
                    if ~isfield(obj.dlogpdf_, 'sigma')
                        obj.dlogpdf_.sigma = -(repmat(obj.sigma_inv_, obj.m_, 1) - ...
                        outer_product((obj.sigma_inv_*(obj.data_-obj.params_.mean)')', ...
                                      (obj.data_-obj.params_.mean)*obj.sigma_inv_))/2;
                    end
                otherwise
                    error("Derivation not possible")        
            end
            
            dlogpdf = obj.dlogpdf_.(dev_type);
        end
        
        function fig = plot(obj, options, fig, varargin)
           if nargin < 3; fig = figure; else; figure(fig); end
           
           if nargin > 1; obj.check_options(options); else
               options = struct;
               obj.check_options(options);
           end
           
           switch obj.d_
               case 1
                   if ~obj.is_grid_
                       obj.set_grid(obj.fig_options_.res, ...
                           obj.fig_options_.grid(1,1), obj.fig_options_.grid(1,2));
                   end
                   obj.pdf;
                   plot(obj.grid_{1}, obj.pdf_, varargin{:});
               otherwise
                   if ~obj.is_grid_
                       obj.set_grid(obj.fig_options_.res, ...
                           obj.fig_options_.grid(1,1), obj.fig_options_.grid(1,2), ...
                           obj.fig_options_.grid(2,1), obj.fig_options_.grid(2,2));
                   end
                   obj.pdf;
                   surf(obj.grid_{1}, obj.grid_{2}, reshape(obj.pdf_,size(obj.grid_{1},1),size(obj.grid_{1},2)))
           end     
        end
        
        function fig = contour(obj, options, fig)
           if nargin < 3; fig = figure; else; figure(fig); end
           
           if nargin > 1; obj.check_options(options); else
               options = struct;
               obj.check_options(options);
           end
            
           switch obj.d_
               case 1
                   error('It does not make sense contour for 1D');
               case 2
                  if ~obj.is_grid_
                      obj.set_grid(obj.fig_options_.res, ...
                          obj.fig_options_.grid(1,1), obj.fig_options_.grid(1,2), ...
                          obj.fig_options_.grid(2,1), obj.fig_options_.grid(2,2));
                  end
                  obj.pdf;
                  contourf(obj.grid_{1}, obj.grid_{2}, reshape(obj.pdf_,size(obj.grid_{1},1),size(obj.grid_{1},2)));
                  hold on;
                  axis equal;
                  if obj.fig_options_.plot_stream
                      obj.pdf_grad;
                      streamslice(obj.grid_{1}, obj.grid_{2}, ...
                          reshape(obj.dpdf_.data(:,1),size(obj.grid_{1},1),size(obj.grid_{1},2)), ...
                          reshape(obj.dpdf_.data(:,2),size(obj.grid_{1},1),size(obj.grid_{1},2)));
                  end
                   
               otherwise
                   if ~obj.is_grid_
                       obj.set_grid(obj.fig_options_.res, ...
                           obj.fig_options_.grid(1,1), obj.fig_options_.grid(1,2), ...
                           obj.fig_options_.grid(2,1), obj.fig_options_.grid(2,2), ...
                           obj.fig_options_.grid(3,1), obj.fig_options_.grid(3,2));
                   end
                   obj.pdf;   
                   contour3(obj.grid_{1}, obj.grid_{2}, obj.grid_{3}, reshape(obj.pdf_(:,1:3),size(obj.grid_{1},1),size(obj.grid_{1},2),size(obj.grid_{1},3)));
                   hold on;
                   axis equal;
                   if obj.fig_options_.plot_stream; end
            end
        end
    end
    
    methods (Access = protected)
        function check(obj)
            if ~obj.is_params_
                for i  = 1 : length(obj.params_name_)
                   assert(isfield(obj.params_,obj.params_name_{i}), '"%s" parameter missing', obj.params_name_{i})
                end
                obj.is_params_ = true;
            end
            
            assert(obj.is_data_, 'Data missing');
        end
        
        function check_options(obj, options)
            if isfield(options,'grid')
                obj.fig_options_.grid = options.grid;
                obj.is_grid_ = false;
            elseif ~obj.is_grid_
                obj.fig_options_.grid = [zeros(obj.d_,1), 100*ones(obj.d_,1)];
            end

            if isfield(options,'res'); obj.fig_options_.res = options.res; else
                obj.fig_options_.res = 100;
            end

            if isfield(options,'plot_stream'); obj.fig_options_.plot_stream = options.plot_stream; else
                obj.fig_options_.plot_stream = false;
            end
        end
        
        function reset(obj)
            obj.is_pdf_ = false;
            obj.is_logpdf_ = false;
            obj.dpdf_ = rmfield(obj.dpdf_, fieldnames(obj.dpdf_));
            obj.dlogpdf_ = rmfield(obj.dlogpdf_, fieldnames(obj.dlogpdf_));
        end
    end
    
    properties
        params_name_ = {'mean', 'sigma'}
        params_ = struct
        
        data_
        grid_
        m_
        d_
        sigma_inv_
        L_
        
        pdf_
        logpdf_
        
        dpdf_ = struct
        dlogpdf_ =  struct
        
        fig_options_
        
        is_params_ = false
        is_data_ = false
        is_grid_ = false
        is_pdf_ = false
        is_logpdf_ = false
    end
end

