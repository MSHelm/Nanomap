function [M, TF] = padcatcell(varargin)
% PADCATCELL - Concatenate cell arrays of unequal lengths
%
%   M = padcatcell(C1, C2, ..., CN} concatenates the cell arrays C1 through
%   CN into one large cell array M.  These cells do not have to have the
%   same number of elements.  M will have N rows and the k-th row will
%   contain the elements of the k-th cell array.  Shorter inputs will be
%   padded with empty cells.  Note that the cells are always concatenated
%   along the first dimension (in contrast to PADCAT).
%
%   [M, TF] = padcatcell (...) will return a logical array TF with the same
%   size as M.  TF is true where M holds an element from the original input.
%   This is usefull to replace the padded empty cells with something else.
% 
%   Example:
%     A = {'apple','ball','cat'}    
%     B = {} ;                       % empty
%     C = {'dog' ; 'egg'}            % note the column orientation
%     [M, TF] = padcatcell(A, B, C)
%     M(~TF) = {'-'}
%
%   Note: the cells are not limited to cell array of strings, they can hold
%         any type of element.
%
%   See also CAT, PADCAT, NONES, STRVCAT, GROUP2CELL, CATSTRUCT

% Should work in most versions of matlab (tested in R2015a)
% version 1.11 (mar 2017)
% (c) Jos van der Geest
% email: samelinoa@gmail.com

% History
%  1.0 (mar 2017) - created, inpsired by question of "MIDHUN" regarding
%    PADCAT, http://www.mathworks.com/matlabcentral/fileexchange/22909
%  1.11 (mar 2017) - added a note that cells can hold anything

% Make all inputs row vectors and get the number of elements for each input
% work backwards to pre-allocate N automatically
C = varargin ;
for k=numel(C):-1:1,
    if ~iscell(C{k})
        error('All inputs should be cell arrays.') ;
    end
    N(k,1) = numel(C{k}) ; % number of elements
    C{k} = reshape(C{k},N(k,1),1) ; % make column vectors
end

% Create a logical vector with true values where to put the cells
% see NONES, File Exchange #10622
% https://www.mathworks.com/matlabcentral/fileexchange/10622-nones
TF = (cumsum([N(:) repmat(-1,numel(N),max(N)-1)],2)>0).' ;

% fill the output cell, default to empty cells
M = cell(size(TF)) ;
M(TF) = cat(1,C{:}) ;

% make row oriented matrices
M = M.' ;
TF =TF.' ;

