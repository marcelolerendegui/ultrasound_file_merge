function [varargout] = cut_data(indices, varargin)
    for i = 1:1:nargin-1
        a = varargin{i};
        a = a(~indices);
        varargout{i} = a;
    end       
end