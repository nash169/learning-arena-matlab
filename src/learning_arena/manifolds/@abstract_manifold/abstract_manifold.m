classdef abstract_manifold < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    % Constructor
    
%=== PUBLIC ===% 
    properties
        % List of set-able paramters
        params_list_
    end
    
    methods
        % Constructor
        function obj = abstract_manifold(varargin)
            % Define object structure
            obj.signature;
            
            % Set parameters
            if nargin > 0; obj.set_params(varargin{:}); end
            
            % Reset bools
            obj.is_data_ = false;
            obj.is_params_ = false;
            obj.is_grid_ = false;
            obj.reset;
        end
        
        % Set the parameters
        set_params(obj, varargin)
        
        % Set the data
        set_data(obj, varargin)
        
        % Get the parameters
        params = params(obj, parameter)
        
        % Get the data
        data = data(obj)
        
        % Get the embedding (into an euclidian space?)
        phi = embedding(obj,data)
        
        % Sample points (uniformly?)
        x = sample(obj, num_points)
        
        % Plot the embedding
        fig = plot_embedding(obj, options, fig, varargin)
    end
    
%=== PROTECTED ===%    
    properties (Access = protected)
        % Internal parameters structure
        params_
        
        % Number of samples
        m_
        
        % Manifold dimension
        dim_
        
        % Dataset
        data_
        
        % Chart map domain
        extrema_
        
        % Embedding
        phi_
        
        % Sampled points
        samples_
        
        % Figure options structure
        fig_options_
        
        % Bool to check the presence of the parameters
        is_params_
        
        % Bool to check the presence of the dataset
        is_data_
        
        % Bool to check the presence of a grid of points
        is_grid_
        
        % Bool to check the presence of the embedding
        is_embedding_
        
        % Bool to check if the data are sampled
        is_sampled_
    end
    
    methods (Access = protected)
        % Check the presence of the necessaries for computation
        check(obj)
        
        % Reset internal state
        reset(obj)
    end
    
%=== ABSTRACT ===%
    methods (Abstract = true, Access = protected)
        % Define parameters and other options for the specific sub-class
        signature(obj)
        
        % Calculate the embedding
        calc_embedding(obj)
        
        % Calculate samples
        calc_sampled(obj)
    end
end

