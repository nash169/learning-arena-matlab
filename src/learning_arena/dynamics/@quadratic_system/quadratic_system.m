classdef quadratic_system < abstract_dynamics
    %QUADRATIC_SYSTEM Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = quadratic_system(varargin)
            %QUADRATIC_SYSTEM Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_dynamics(varargin{:});
            if ~isfield(obj.params_, 'attractor'); obj.params_.attractor = 0; end
            if ~isfield(obj.params_, 'constant'); obj.params_.constant = 0; end
        end

    end

    %=== PROTECTED ===%
    methods (Access = protected)
        signature(obj)
        f = calc_field(obj, x)
    end

end
