classdef kernel_expansion < handle
    %KERNEL_EXPANSION Summary of this class goes here
    %   Limited to two inputs kernels right now
    
%=== PUBLIC ===%
    properties
        % List of hyper-parameters.
        h_params_list_
        
        % List of parameters.
        params_list_
    end
    
    methods
        % Constructor. In the constructor you can pass the parameters 
        % defining the kernel. You can pass all of them or a part and set 
        % the rest using the apposite function "set_params".
        function obj = kernel_expansion(varargin)
            %KERNEL_EXPANSION Construct an instance of this class
            %   Detailed explanation goes here
            
            % Define the parameters of the model.
            obj.signature;
            
            % Set the parameters if present.
            if nargin > 0; obj.set_params(varargin{:}); end
            
            % Set default parameters
            if  ~isfield(obj.params_, 'order'); obj.params_.order = 'ref-test'; end
            
            % Init bool variables.
            obj.is_params_ = false;
            obj.is_data_ = false;
            obj.is_grid_ = false;
            obj.is_fig_options_ = false;
            obj.reset;
        end
        
        % Set the parameters of the kernel. Set the parameters that you
        % like. Every time you set a parameters the kernel will be
        % recalculated
        function set_params(obj, varargin)
            for i = 1 : 2 : length(varargin)
                if logical(sum(strcmp(obj.h_params_list_, varargin{i})))
                    obj.h_params_.(varargin{i}) = varargin{i+1};
                elseif logical(sum(strcmp(obj.params_list_, varargin{i})))
                    obj.params_.(varargin{i}) = varargin{i+1};
                else
                    error('"%s" parameter not present', varargin{i})
                end
            end
            
            obj.is_params_ = false;
            obj.reset;
        end
        
        % Set the test points. The points either a matrix of points or as
        % list of grid resolution and boundaries for each axes.
        function set_data(obj, varargin)
            if length(varargin) == 1
                obj.data_ = varargin{1};
            else
                assert(isscalar(varargin{1}), 'The first entry has to be the resolution.')
                d = length(varargin(2:end));
                grid = cell(1,d/2);
                counter = 1;

                for i = 2 : 2 : d
                    grid{counter} = linspace(varargin{i}, varargin{i+1}, varargin{1});
                    counter = counter + 1;
                end

                [obj.grid_{1:length(grid)}] =  ndgrid(grid{:});
                obj.grid_ = cellfun(@(x) permute(x, [2 1 3:ndims(x)]),obj.grid_, 'UniformOutput',false);
                obj.data_ = reshape([obj.grid_{:}], [], length(obj.grid_));
                obj.is_grid_ = true;
            end

            [obj.n_, ~] = size(obj.data_);
            obj.is_data_ = true;
            obj.reset;
        end
        
        % Get the parameters of the kernel.
        function [params, params_aux] = params(obj, parameter)
            assert(logical(sum(strcmp(obj.h_params_list_, parameter))), ...
                '"%s" parameter not present', parameter)
            if nargin < 2 
                params = obj.h_params_;
                if nargout > 1; params_aux = obj.params_; end
            else
                assert(nargout < 2, 'Just one output allowed')
                
                if logical(sum(strcmp(obj.h_params_list_, parameter)))
                    params = obj.h_params_.(parameter);
                elseif logical(sum(strcmp(obj.params_list_, parameter)))
                    params = obj.params_.(parameter);
                else
                    error('"%s" parameter not present', parameter)
                end
                
            end
        end
        
        % Get the training or test points.
        function data = data(obj)
            data = obj.data_;
        end
        
        % Get the kernel expansion.
        function psi = expansion(obj, varargin) 
            if nargin > 1; obj.set_data(varargin{:}); end
            obj.check;
            assert(obj.is_data_, "Test set not present");
            
            if ~obj.is_psi_
                switch obj.params_.order
                    case 'ref-test'
                        obj.psi_ = obj.sum_kernels(obj.h_params_.kernel.kernel( ...
                            obj.params_.reference,obj.data_));
                    case 'test-ref'
                        obj.psi_ = obj.sum_kernels(obj.h_params_.kernel.kernel( ...
                            obj.data_,obj.params_.reference));
                    otherwise
                        error('Case not found')
                end
                
                obj.is_psi_ = true;
            end
            
            if nargout > 0; psi = obj.psi_; end
        end
        
        % Get the gradient of the kernel expansion. The gradient is taken
        % by default with respect to the test points. The trining points
        % are considered to be parameters. About this, in the future it
        % would be possible to set them among the parameters instead of
        % through set_data. It is necessary to think about that. It is also
        % important to think about the order in the kernel: 
        % k(x_train, x_test) vs k(x_test, x_train).
        % With a symmetric kernel it makes no difference but with a non
        % symmetric one?
        function dpsi = gradient(obj, varargin) 
            if nargin > 1; obj.set_data(varargin{:}); end
            obj.check;
            assert(obj.is_data_, "Test set not present");
            
            if ~obj.is_dpsi_
                switch obj.params_.order
                    case 'ref-test'
                        dk = obj.h_params_.kernel.gradient( ...
                            obj.params_.reference,obj.data_);
                        obj.dpsi_ = obj.sum_kernels(dk(:,:,2));
                    case 'test-ref'
                        dk = obj.h_params_.kernel.gradient( ...
                            obj.data_,obj.params_.reference);
                        obj.dpsi_ = obj.sum_kernels(dk(:,:,1));
                    otherwise
                        error('Case not found')
                end
                
                obj.is_dpsi_ = true;
            end
            
            if nargout > 0; dpsi = obj.dpsi_; end
        end
        
        % Get the hessian. Also the hessian is taken with respect to the
        % test points. See above
        function d2psi = hessian(obj, varargin)
            if nargin > 1; obj.set_data(varargin{:}); end
            obj.check;
            assert(obj.is_test_, "Test set not present");
            
            if ~obj.is_d2psi_
                switch obj.params_.order
                    case 'ref-test'
                        d2k = obj.h_params_.kernel.hessian( ...
                            obj.params_.reference,obj.data_);
                        obj.d2psi_ = obj.sum_kernels(d2k(:,:,4));
                    case 'test-ref'
                        d2k = obj.h_params_.kernel.hessian( ...
                            obj.data_,obj.params_.reference);
                        obj.d2psi_ = obj.sum_kernels(d2k(:,:,1));
                    otherwise
                        error('Case not found')
                end
                
                obj.is_d2psi_ = true;
            end          
            
            if nargout > 0; d2psi = obj.d2psi_; end
        end
        
        % Get the derivative with respect to the hyper-parameters
        function [dp, n] = pgradient(obj, param, data)
            if nargin < 2; param = obj.h_params_list_; end
            if nargin > 2; obj.set_data(data); end
            obj.check;
            assert(obj.is_test_, "Test set not present");
            
            for i = 1 : length(param)
                if ~isfield(obj.dp_, param{i})
                    switch param{i}
                        case 'alpha'
                            switch obj.params_.order
                                case 'ref-test'
                                    obj.dp_.alpha = obj.h_params_.kernel.gramian(obj.params_.reference,obj.data_);
                                case 'test-ref'
                                    obj.dp_.alpha = obj.h_params_.kernel.gramian(obj.params_.reference,obj.data_);
                                otherwise
                                    error('Case not found')
                            end
                        case 'kernel'
                            obj.dp_.kernel = obj.h_params_.kernel.pgradient;
                        otherwise
                            obj.dp_.(param{i}) = obj.calc_pgradient(param{i});
                    end
                end
            end
            
            dp = obj.dp_;
            
            if nargout > 1; n = obj.num_params(param); end
        end
        
        % Surface plot of the kernel expansion.
        function fig = plot(obj, options, fig, varargin)           
           if nargin < 3; fig = figure; else; figure(fig); end
           if nargin < 2; options = struct; end
           obj.check;
           
           obj.fig_options(options);
           
           if ~obj.is_grid_
               obj.set_data(obj.fig_options_.res, obj.fig_options_.grid{:});
               obj.is_grid_ = true;
               obj.is_data_ = true;
           end
           
           psi = obj.expansion;
           
           switch obj.d_
               case 1
                   plot(obj.grid_{1}, psi, varargin{:});
               otherwise
                   surf(obj.grid_{1}, obj.grid_{2}, ...
                       reshape(psi,size(obj.grid_{1},1),size(obj.grid_{1},2)))
           end
        end
        
        % Contour plot of the kernel expansion.
        function fig = contour(obj, options, fig)
           if nargin < 3; fig = figure; else; figure(fig); end
           if nargin < 2; options = struct; end
           obj.check;
           
           obj.fig_options(options);
           
           if ~obj.is_grid_
               obj.set_data(obj.fig_options_.res, obj.fig_options_.grid{:});
               obj.is_grid_ = true;
               obj.is_data_ = true;
           end
           
           psi = obj.expansion;
           
           switch obj.d_
               case 1
                   error('It does not make sense contour for 1D');
               case 2
                  contourf(obj.grid_{1}, obj.grid_{2}, ...
                      reshape(psi,size(obj.grid_{1},1),size(obj.grid_{1},2)));
                  hold on;
                  axis equal;
                  
                  if obj.fig_options_.plot_stream
                      dpsi = obj.gradient;
                      h = streamslice(obj.grid_{1}, obj.grid_{2}, ...
                          reshape(dpsi(:,1),size(obj.grid_{1},1),size(obj.grid_{1},2)), ...
                          reshape(dpsi(:,2),size(obj.grid_{1},1),size(obj.grid_{1},2)));
                      set(h,'Color','r');
                  end
                   
                  if obj.fig_options_.plot_data
                    scatter(obj.params_.reference(:,1), obj.params_.reference(:,2), ...
                        40, obj.fig_options_.colors, 'filled','MarkerEdgeColor',[0 0 0])
                  end
                   
               otherwise 
                   contour3(obj.grid_{1}, obj.grid_{2}, obj.grid_{3}, ...
                       reshape(psi(:,1:3),size(obj.grid_{1},1),size(obj.grid_{1},2),size(obj.grid_{1},3)));
                   hold on;
                   axis equal;
                   
                   if obj.fig_options_.plot_stream
%                        dpsi = obj.gradient;
                   end
                   if obj.fig_options_.plot_data
                        scatter3(obj.params_.reference(:,1), obj.params_.reference(:,2), obj.params_.reference(:,3), ...
                            40, obj.fig_options_.colors, 'filled','MarkerEdgeColor',[0 0 0])
                   end
           end
           axis([obj.fig_options_.grid{:}]) 
        end
    end
    
%=== PROTECTED ===% 
    properties (Access = protected)
        % Hyper-parameters. Inside this struct there are all the parameters
        % with respect to it is possible to derive the model.
        h_params_
        
        % Parameters. Inside the struct there are all the parmeters, that
        % can be optional or not, to characterize the model. It is not
        % possible to derive the model with respect to these parameters.
        params_
        
        % Test point for evaluating the model. The gradient and the hessian
        % of the model are taken with respect to this variable.
        data_
        
        % Variable the store the test points in a grid for plotting
        % purpose.
        grid_
        
        % Number of reference points.
        m_
        
        % Number of test points.
        n_
        
        % Dimension of the space.
        d_
        
        % Kernel expansion evaluated at the test points.
        psi_
        
        % Gradient of the kernel expansion evaluated at the test points.
        dpsi_
        
        % Hessian of the kernel expansion evaluated at the test points.
        d2psi_
        
        % Gradient of the kernel expansion with respect to the
        % hyper-parameters
        dp_
        
        % Figure's options
        fig_options_
        
        % Bool variable to assess if all the parameters have been set.
        % correctly.
        is_params_
        
        % Bool variable to assess if the test points have been set.
        is_data_
        
        % Bool variable to assess if a grid for plotting is present or not.
        is_grid_
        
        % Bool variable to assess if tigure's option are set or not.
        is_fig_options_
        
        % Bool variable to assess if the evaluation of the expansion is
        % already available or not.
        is_psi_
        
        % Bool variable to assess if the evaluation of the expansion's
        % gradient is already available or not.
        is_dpsi_
        
        % Bool variable to assess if the evaluation of the expansion's
        % hessian is already available or not.
        is_d2psi_
    end
    
    methods (Access = protected)
        % Define the parameters of the expansion
        function signature(obj)
            obj.h_params_list_ = {'kernel', 'weights'};
            obj.params_list_ = {'reference', 'order'};
        end
        
        % Check data and parameters.
        function check(obj)  
            if ~obj.is_params_
                for i  = 1 : length(obj.h_params_list_)
                   assert(isfield(obj.h_params_,obj.h_params_list_{i}), ...
                       "Define %s", obj.h_params_list_{i});
                end
                
                for i  = 1 : length(obj.params_list_)
                   assert(isfield(obj.params_,obj.params_list_{i}), ...
                       "Define %s", obj.params_list_{i});
                end
                
                obj.is_params_ = true;
            end
            
            [obj.m_, obj.d_] = size(obj.params_.reference);
        end
        
        % Reset bools
        function reset(obj)
            obj.is_psi_ = false;
            obj.is_dpsi_ = false;
            obj.is_d2psi_ = false; 
        end
        
        % Reshape the eigefunction in mxnxd tensor
        function k_sum = sum_kernels(obj, v)
            k_sum = permute(sum(reshape(repmat(obj.h_params_.weights, obj.n_,1).*v, obj.m_, obj.n_, []),1), [2 3 1]);
        end
        
        function calc_pgradient(param)
           error('Parameter %s is not present', param); 
        end
        
        % Set figure options
        function fig_options(obj, options)
            if isfield(options,'grid')
                obj.fig_options_.grid = num2cell(c_reshape(options.grid,[],1));
                obj.is_grid_ = false;
            elseif ~obj.is_grid_
                obj.fig_options_.grid = num2cell(c_reshape([zeros(obj.d_,1), 100*ones(obj.d_,1)],[],1));
            end

            if isfield(options,'res'); obj.fig_options_.res = options.res; else
                obj.fig_options_.res = 100;
            end

            if isfield(options, 'plot_data'); obj.fig_options_.plot_data = options.plot_data; else
                obj.fig_options_.plot_data = false;
            end
            
            if isfield(options, 'colors'); obj.fig_options_.colors = options.colors; else
                obj.fig_options_.colors = 'r';
            end

            if isfield(options,'plot_stream'); obj.fig_options_.plot_stream = options.plot_stream; else
                obj.fig_options_.plot_stream = false;
            end
        end
    end
end

