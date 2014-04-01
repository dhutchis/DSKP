% subclass containers.Map to return -Inf as a default value
% also 2-dimensional map: dpmap(w,v) maps correctly
% note: uses 32-bit integers instead of 64
% future note: consider specializing to double values only
classdef DPmap < handle
    properties (Constant)
        default_val = -Inf;
        display_default_val = false;
    end
    properties (SetAccess=private, GetAccess=private)
        mapw;
    end
    methods
        function this = DPmap()
            % constructor
            this.mapw = containers.Map('KeyType','int32','ValueType','any');
        end
        function val = subsref(this,S)
            if ~strcmp(S.type,'()')
                error('only () indexing supported');
            end
            if ~all(size(S.subs) == [1 2])
                error('please index with two indices like so: dpmap(w,v)');
            end
            w = S.subs{1}; v = S.subs{2};
            % ':' cases
            if w == ':' && v == ':'
                for keyw = cell2mat(keys(this.mapw))
                    mapv = this.mapw(keyw);
                    for keyv = cell2mat(keys(mapv))
                        fprintf('(%d,%d) = %d\n',keyw,keyv,mapv(keyv));%['(' keyw ',' keyv ') = ' mapv(keyv)]);
                    end
                end
            elseif v == ':'
                mapv = this.mapw(w);
                for key = cell2mat(keys(mapv))
                    fprintf('(%d,%d) = %d\n',w,key,mapv(key));
                end
            else
                if ~this.isKey(w,v)
                    % NAH: return -Inf for negative entries, or if no value currently assigned
                    %   any(S.subs < 0) ||
                    val = this.default_val;
                else
                    % first subsref returns map of v->f, second returns f
                    mapv = this.mapw(w);
                    val = mapv(v);
                end
            end % if
        end % function subsref
        
        function this = subsasgn(this, S, B)
            if ~strcmp(S.type,'()')
                error('only () indexing supported');
            end
            if ~all(size(S.subs) == [1 2])
                error('please index with two indices like so: dpmap(w,v)');
            end
            if B == this.default_val && ~this.display_default_val
                % sparse representation; don't assign default value
                return
            end
            w = S.subs{1}; v = S.subs{2};
            if ~this.mapw.isKey(w)
                this.mapw(w) = containers.Map('KeyType','int32','ValueType','any');
            end
            mapv = this.mapw(w);
            mapv(v) = B; %#ok<NASGU> this achieves a desired side effect
        end
        
        function res = isKey(this,w,v)
            % Returns 1 if (w,v) was previously assigned; otherwise 0
            res = this.mapw.isKey(w) && this.mapw(w).isKey(v);
        end
    end
    
end