function [minval, minkey] = minMap1(m)
% find the minimum key and value of a component.Map object
    if ~isa(m,'containers.Map')
        error('only runs when given a component.Map');
    end
    [minval, minidx] = min(cell2mat(values(m)));
    tmp = keys(m);
    minkey = tmp{minidx};
end
