classdef manifold_learning < handle
    %MANIFOLD_LEARNING Summary of this class goes here
    %   Detailed explanation goes here
    methods
        % Construct - Possible to set parameters directly, not data
        function obj = manifold_learning(varargin)
            %MANIFOLD_LEARNING Construct an instance of this class
            %   Detailed explanation goes here
            obj.signature;
            if nargin > 0; obj.set_params(varargin{:}); end
            obj.reset;
        end
        
        % Set parameters. It is possible to set just the parameters shown
        % in 'params_name_'
        function set_params(obj, varargin)
            for i = 1 : 2 : length(varargin)
                assert(logical(sum(strcmp(obj.params_name_, varargin{i}))), '"%s" parameter not present', varargin{i})
                obj.params_.(varargin{i}) = varargin{i+1};
            end
            
            obj.is_params_ = false;
            obj.reset;
        end
        
        % Set data. This is the list of all points inside the training
        % dataset
        function set_data(obj, data)
            obj.data_ = data;
            [obj.m_, obj.d_] = size(data);
            
            obj.is_data_ = true;
            obj.reset;
        end
        
        % Get the parameters. Not very useful at the moment
        function params = params(obj, parameter)
            assert(logical(sum(strcmp(obj.params_name_, parameter))), ...
                '"%s" parameter not present', parameter)
            if nargin < 2 
                params = obj.params_;
            else
                params = obj.params_.(parameter);
            end
        end
        
        % Get the training dataset. Not very useful at the moment
        function data = data(obj)
            data = obj.data_;
        end
        
        % Set graph. For each manifold learning algorithm it is
        % possible to set the graph. The weights of the edges will be
        % define by the similarity matrix. Whereas there is no edege the
        % weight is 0
        function set_graph(obj, G)
            obj.graph_ = G;
            obj.with_graph_ = true;
            obj.is_graph_ = true;
            obj.reset;
        end
        
        % Set graph options. 
        function graph_options(obj, varargin)
%             obj.graph_options_ = [obj.graph_options_, varargin];
            obj.graph_options_ = varargin;
            obj.with_graph_ = true;
            obj.is_graph_ = false;
            obj.reset;
        end
        
        % Get the similarity matrix. The graph is automatically applied to
        % the similarity if present
        function S = similarity(obj, data)
            if nargin > 1; obj.set_data(data); end
            obj.check;
            
            if ~obj.is_similarity_
                obj.similarity_ = obj.params_.kernel.gramian(obj.data_,obj.data_);
                if obj.with_graph_
                    obj.similarity_ = obj.similarity_.*obj.graph;
                end
                obj.is_similarity_ = true;
            end
            
            S = obj.similarity_;
        end
        
        % Solve the (generalized) eigenvalue problem. By default both the
        % right and the left eigenvectors are computes, plus the
        % eigenvalues
        function [D,V,W] = eigensolve(obj, data)
            if nargin > 1; obj.set_data(data); end
            
            if ~obj.is_eigen_
                [obj.right_vec_, obj.eig_, obj.left_vec_] = obj.solve;
                obj.is_eigen_ = true;
            end
            
            if nargout > 0; D = obj.eig_; end
            if nargout > 1; V = obj.right_vec_; end
            if nargout > 2; W = obj.left_vec_; end
        end
        
        % Get the deegre matrix. By default it is computed based on the
        % similarity matrix.
        function D = degree(obj, M)
            if nargin < 2; M = obj.similarity; end
            
            D = diag(sum(M,2));
        end
        
        % Get graph. It returns a logical matrix where entries equal to 1
        % indicates the presence of an edge between nodes.
        function G = graph(obj, data, varargin)
            if nargin > 1; obj.set_data(data); end
            if nargin > 2; obj.graph_options_ = varargin; end
            
            if ~obj.is_graph_
                obj.graph_ = graph_build(obj.data_, obj.graph_options_{:});
                obj.is_graph_ = true;
                obj.with_graph_ = true;
            end
            
            obj.reset;
            if nargout > 0; G = obj.graph_; end
        end
        
        % Get the eigenfunction. It computes the continuous eigenfunction
        % as a linear combination of kernels weighted by a specific
        % eigenvector
        function funs = eigenfun(obj, x, vecs, data)
            if nargin < 3; vecs = 1; end
            if nargin > 3; obj.set_data(data); end
            obj.eigensolve;
            
            funs = zeros(size(x,1), length(vecs));
            for i = 1:length(vecs)
                obj.expansion_.set_params('weights', obj.right_vec_(:,vecs(i)));
                funs(:,i) = obj.expansion_.expansion(obj.data_,x);
            end
        end
        
        % Get the emebedding. Returns the embedding space related to the
        % specified eigenvectors. The embedding is built on the left
        % eigenvectors
        function U = embedding(obj, space)
            if nargin < 1; space = 1; end
            [~,U] = obj.eigensolve;
            U = U(:, space);
        end
        
        % Plot eigenfunctions
        function varargout = plot_eigenfun(obj, space, varargin)
            if nargin < 2; space = 1; end
            
            options = struct;
            if nargin > 2
                for i = 1 : 2 : length(varargin)
                    options.(varargin{i}) = varargin{i+1};
                end
            end
            
            if ~obj.is_eigen_; obj.eigensolve; end
            varargout = cell(length(space),1);
            
            for i = 1 : length(space)
                obj.expansion_.set_params('weights', obj.right_vec_(:,space(i)));
                varargout{i} = figure;
                subplot(1,2,1)
                obj.expansion_.plot(options, varargout{i});
                title(['Eigenfunction ', num2str(space(i)), ' surface'])
                subplot(1,2,2)
                obj.expansion_.contour(options, varargout{i});
                title(['Eigenfunction ', num2str(space(i)), ' contour'])
            end
        end
        
        % Plot spectrum
        function fig = plot_spectrum(obj, num_eig)
            if nargin < 2; num_eig = 1:10; end
            lambdas = diag(obj.eigensolve);
            fig = figure;
            plot(num_eig, lambdas(num_eig), '-o')
            grid on
            title(['Spectrum from eigenvalue ', num2str(num_eig(1)), ' to ', num2str(num_eig(end))])
        end
        
        % Plot embedding
        function fig = plot_embedding(obj, space, fig)
            if nargin < 2; space = [1,2]; end
            if nargin < 3; fig = figure; else; figure(fig); end
            assert(length(space)~=1, '1D?')
            
            U = obj.embedding(space);
            
            if length(space) == 2
                scatter(U(:,1),U(:,2), 20, 'r','filled','MarkerEdgeColor',[0 0 0]);
                title(['Embedding space of eigenvectors: ', num2str(space(1)), ' and ', num2str(space(2))]);
            else
                scatter3(U(:,1),U(:,2),U(:,3), 20, 'r','filled','MarkerEdgeColor',[0 0 0]);
                title(['Embedding space of eigenvectors: ', num2str(space(1)), ', ', num2str(space(2)), ' and ', num2str(space(3))]);
            end
            grid on;
        end
        
        % Plot graph
        function fig = plot_graph(obj)
            G = digraph(obj.graph);
            nodes = {'XData', obj.data_(:,1), 'YData', obj.data_(:,2)};
            if obj.d_ > 2; nodes = [nodes, 'ZData', obj.data_(:,3)]; end
            fig = figure;
            plot(G, nodes{:});
        end
        
        % Plot similarity matrix
        function fig = plot_similarity(obj)
           S = obj.similarity;
           fig = figure;
           pcolor([S, zeros(size(S,1), 1); zeros(1, size(S,2)+1)])
           title('Similarity matrix');
           axis image
           axis ij
           colorbar
        end
    end
    
    methods (Access = protected)
        function check(obj)
            assert(obj.is_data_, "Data not present");
            
            if ~obj.is_params_
                for i  = 1 : length(obj.params_name_)
                   assert(isfield(obj.params_,obj.params_name_{i}), ...
                       '"%s" parameter missing', obj.params_name_{i})
                end
                obj.is_params_ = true;
            end
            
            if ~obj.is_expansion_
                obj.expansion_ = kernel_expansion('kernel', obj.params_.kernel);
                obj.expansion_.set_data(obj.data_);
                obj.is_expansion_ = true;
            end
        end
        
        function reset(obj)
            obj.is_eigen_ = false;
            obj.is_expansion_ = false;
            obj.is_similarity_ = false;
            obj.is_graph_ = false;
        end
    end
    
    methods (Abstract = true, Access = protected)
        signature(obj);
        solve(obj);
    end
    
    properties
        type_
        params_name_
    end
    
    properties (Access = protected)
        % Data and parameters
        data_
        is_data_
        params_
        is_params_
        
        % Dimensions
        m_
        d_

        % Embedding & Eigenfunctions
        expansion_
        is_expansion_
        
        % Graph
        graph_
        graph_options_ = {}
        is_graph_
        with_graph_
        
        % Matrices
        similarity_
        is_similarity_
        
        % Eigendecomposition
        right_vec_
        eig_
        left_vec_
        is_eigen_
    end
end
