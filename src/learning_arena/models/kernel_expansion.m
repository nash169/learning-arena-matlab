classdef kernel_expansion < handle
    %KERNEL_EXPANSION Summary of this class goes here
    %   Limited to two inputs kernels right now
    
    methods
        function obj = kernel_expansion(varargin)
            %KERNEL_EXPANSION Construct an instance of this class
            %   Detailed explanation goes here
            if nargin > 0; obj.set_params(varargin{:}); end
        end
        
        function set_params(obj, varargin)
            for i = 1 : 2 : length(varargin)
                assert(logical(sum(strcmp(obj.params_name_, varargin{i}))), '"%s" parameter not present', varargin{i})
                obj.params_.(varargin{i}) = varargin{i+1};
            end
            obj.is_params_ = false;
            obj.reset;
        end
        
        function set_data(obj, data)
            obj.data_ = data;
            [obj.m_, obj.d_] = size(data);
            
            obj.is_data_ = true;
            obj.reset;
        end
        
        function set_test(obj, test)
            obj.test_ = test;
            [obj.n_, ~] = size(test);
            
            obj.is_test_ = true;
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
            
            obj.set_test(reshape([obj.grid_{:}], [], length(obj.grid_)));
            
            obj.is_grid_ = true;
        end
        
        function psi = expansion(obj, varargin) 
            if nargin > 1; obj.set_input(varargin{:}); end
            obj.check;
            assert(obj.is_test_, "Test set not present");
            
            if ~obj.is_psi_
                if strcmp(obj.params_.kernel.type_ , 'scalar_valued')
                     obj.psi_ = obj.sum_kernels(obj.params_.kernel.kernel(obj.data_,obj.test_));
                else
                     obj.psi_ = 0;
                     error('Vector valued kernels not implemented yet')
                end
                obj.is_psi_ = true;
            end
            
            psi = obj.psi_;
        end
        
        function dpsi = gradient(obj, varargin) 
            if nargin > 1; obj.set_input(varargin{:}); end
            obj.check;
            assert(obj.is_data_, "Data set not present");
            assert(obj.is_test_, "Test set not present");
            
            if ~obj.is_dpsi_
                if strcmp(obj.params_.kernel.type_ ,'scalar_valued')
                    dk = obj.params_.kernel.gradient(obj.data_,obj.test_);
                    obj.dpsi_ = obj.sum_kernels(dk(:,:,2));
                else
                     obj.dpsi_ = 0;
                     error('Vector valued kernels not implemented yet')
                end
                obj.is_dpsi_ = true;
            end
            
            dpsi = obj.dpsi_;
        end
        
        function d2psi = hessian(obj, varargin)
            if nargin > 1; obj.set_input(varargin{:}); end
            obj.check;
            assert(obj.is_test_, "Test set not present");
            
            if ~obj.is_d2psi_
                if strcmp(obj.kernel_.type_ ,'scalar_valued')
                    d2k = obj.kernel_.hessian(obj.data_,obj.test_);
                    obj.d2psi_ = obj.sum_kernels(c_reshape(d2k(:,:,4), [], obj.d_^2));
                else
                     obj.d2psi_ = 0;
                     error('Vector valued kernels not implemented yet')
                end
                obj.is_d2psi_ = true;
            end          
            
            d2psi = obj.d2psi_;
        end
        
        function fig = plot(obj, options, fig, varargin)           
           if nargin < 3; fig = figure; else; figure(fig); end
           if nargin < 2; options = struct; end
           
           obj.fig_options(options);
           
           if ~obj.is_grid_
               obj.set_grid(obj.fig_options_.res, obj.fig_options_.grid{:});
           end
           
           obj.expansion;
           
           switch obj.d_
               case 1
                   plot(obj.grid_{1}, obj.psi_, varargin{:});
               otherwise
                   surf(obj.grid_{1}, obj.grid_{2}, ...
                       reshape(obj.psi_,size(obj.grid_{1},1),size(obj.grid_{1},2)))
           end     
        end
        
        function fig = contour(obj, options, fig)
           if nargin < 3; fig = figure; else; figure(fig); end
           if nargin < 2; options = struct; end
           
           obj.fig_options(options);
           
           if ~obj.is_grid_
               obj.set_grid(obj.fig_options_.res, obj.fig_options_.grid{:});
           end
           
           obj.expansion;
           if obj.fig_options_.plot_stream; obj.gradient; end
            
           switch obj.d_
               case 1
                   error('It does not make sense contour for 1D');
               case 2
                  contourf(obj.grid_{1}, obj.grid_{2}, ...
                      reshape(obj.psi_,size(obj.grid_{1},1),size(obj.grid_{1},2)));
                  hold on;
                  axis equal;
                  
                  if obj.fig_options_.plot_stream
                      h = streamslice(obj.grid_{1}, obj.grid_{2}, ...
                          reshape(obj.dpsi_(:,1),size(obj.grid_{1},1),size(obj.grid_{1},2)), ...
                          reshape(obj.dpsi_(:,2),size(obj.grid_{1},1),size(obj.grid_{1},2)));
                      set(h,'Color','r');
                  end
                   
                  if obj.fig_options_.plot_data; end
                   
               otherwise 
                   contour3(obj.grid_{1}, obj.grid_{2}, obj.grid_{3}, ...
                       reshape(obj.psi_(:,1:3),size(obj.grid_{1},1),size(obj.grid_{1},2),size(obj.grid_{1},3)));
                   hold on;
                   axis equal;
                   
                   if obj.fig_options_.plot_stream; end
                   if obj.fig_options_.plot_data; end
            end
        end
    end
    
    methods (Access = protected)
        function k_sum = sum_kernels(obj, v)
            k_sum = permute(sum(reshape(repmat(obj.params_.weights, obj.n_,1).*v, obj.m_, obj.n_, []),1), [2 3 1]);
        end
        
        function set_input(obj, varargin)
            if nargin > 1
                obj.set_data(varargin{1});
            end
            
            if nargin > 2
                if size(varargin{1},2) ~= 1
                    obj.set_test(varargin{2});
                else
                    obj.set_grid(varargin{2:end});
                end
            end
        end
        
        function check(obj)
            % Check params
            if ~obj.is_params_
                for i  = 1 : length(obj.params_name_)
                   assert(isfield(obj.params_,obj.params_name_{i}), "Define %s", obj.params_name_{i});
                end
                obj.is_params_ = true;
                
                assert(obj.is_data_, "Data set not present");
            end   
        end
        
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

            if isfield(options,'plot_stream'); obj.fig_options_.plot_stream = options.plot_stream; else
                obj.fig_options_.plot_stream = false;
            end
        end
        
        function reset(obj)
            obj.is_psi_ = false;
            obj.is_dpsi_ = false;
            obj.is_d2psi_ = false; 
        end
    end
    
    properties
        params_name_ = {'kernel', 'weights'}
        
        % Kernel expansion data
        params_;
        data_;
        grid_;
        test_;
        
        % Dataset dimensions
        m_;
        n_;
        d_;
        
        % Expansion and derivarives
        psi_;
        dpsi_;
        d2psi_;
        
        % Figure's options
        fig_options_;
        
        % Bool necessary variables
        is_params_ = false;
        is_data_ = false;
        is_test_ = false;
        is_grid_ = false;
        is_fig_options_ = false;
        
        
        % Bools calculated variables
        is_psi_;
        is_dpsi_;
        is_d2psi_;
    end
end

