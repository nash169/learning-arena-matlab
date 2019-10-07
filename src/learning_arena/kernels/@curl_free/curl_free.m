classdef curl_free < abstract_kernel
    %CURL_FREE Summary of this class goes here
    %   Detailed explanation goes here

%=== PUBLIC ===%
    properties
        
    end
    
    methods
        function obj = curl_free(varargin)
            %CURL_FREE Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_kernel(varargin{:});
        end
        
    end
    
%=== PROTECTED ===% 
    properties (Access = protected)
        
    end
    
    methods (Access = protected)
        signature(obj);
        
    end
end

