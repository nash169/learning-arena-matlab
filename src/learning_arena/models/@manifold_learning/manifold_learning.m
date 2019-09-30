classdef manifold_learning < handle
    %MANIFOLD_LEARNING Summary of this class goes here
    %   Detailed explanation goes here
    
%=== PUBLIC ===%
    properties
        type_
        params_name_
    end
    
    methods
        % Construct - Possible to set parameters directly, not data
        function obj = manifold_learning(varargin)
            %MANIFOLD_LEARNING Construct an instance of this class
            %   Detailed explanation goes here
            obj.signature;
            if nargin > 0; obj.set_params(varargin{:}); end
            obj.reset;
        end
        
        set_params(obj, varargin)
        
        set_data(obj, data)
        
        params = params(obj, parameter)
        
        data = data(obj)
        
        set_graph(obj, G)
        
        graph_options(obj, varargin)
        
        set_colors(obj, colors)
        
        S = similarity(obj, data)
        
        [D,V,W] = eigensolve(obj, data)
        
        D = degree(obj, M)
        
        G = graph(obj, data, varargin)
        
        funs = eigenfun(obj, x, vecs, data)
        
        U = embedding(obj, space)
        
        varargout = plot_eigenfun(obj, space, varargin)
        
        varargout = plot_eigenvec(obj, space, type)
        
        fig = plot_spectrum(obj, num_eig)
        
        fig = plot_data(obj, data, colors, fig)
        
        fig = plot_embedding(obj, space, colors, fig)
        
        fig = plot_graph(obj, space_type, space)
        
        fig = plot_similarity(obj)
    end
    
%=== PROTECTED ===%
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
        
        % Data colors
        colors_
        is_colors_
    end
    
    methods (Access = protected)
        check(obj)
        
        reset(obj)
    end
    
%=== ABSTRACT ===% 
    methods (Abstract = true, Access = protected)
        signature(obj);
        solve(obj);
    end
end

