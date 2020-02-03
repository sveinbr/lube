classdef struct_ptr < dynamicprops
    %class struct_ptr
    %  Similar to struct, but inheriting the builtin handle class,
    %  thereby avoiding copying itself upon assignment.
    %example:
    %  x = struct_ptr;
    %  x.A = 1;
    %  y = x;
    %  y.A = 2;
    %  Now, disp(y.A) displays the value 2
    %
    % (c) Svein Brekke, Feb 2020. Free to use for any purpose as long as this line is preserved.

    methods
 
        function obj = struct_ptr(varargin)
            if mod(nargin,2) ~= 0
                error('struct_ptr: Input arguments must be specified in name,value pairs')
            end
            for n=1:2:nargin
                addprop(obj,varargin{n});
                obj.(varargin{n}) = varargin{n+1};
            end
        end

        function setfield(obj,name,value)
            if ~isprop(obj,name)
                addprop(obj,name);
            end
            obj.(name) = value;
        end

        function out=getfield(obj,name)
            out = obj.(name);
        end
        
        function obj=rmfield(obj,name)
            rmprops(obj,name);
        end

        function obj = subsasgn(obj,S,value)
            % Supports this syntax when ABC is undefined: x.ABC = 123 
            if strcmp(S.type,'.')
                set(obj,S.subs,value);
            else
                error(['struct_ptr.subsasgn: Unsupported type "',S.type,'"'])
            end
        end

    end % methods

end
