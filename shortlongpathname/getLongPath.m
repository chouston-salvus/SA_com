%getLongPath Convert the specified path to its long form 
%
%  longPathName = getLongPath(pathName) converts the path pathName to its 
%  long form. pathName and longPathName are strings. pathName must be a path 
%  to an existing folder or file.
%
%  getLongPath is based on the Win32 API and therefore is only supported on 
%  Windows systems. For more information about file and path names, see 
%  <a href="http://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx#short_vs._long_names">Naming Files, Paths, and Namespaces</a>.
%
%  Example
%       pathName = 'a b c d e f g h i j';
%       mkdir(pathName);
%       shortPathName = getShortPath(pathName)
%
%       shortPathName =
% 
%       ABCDEF~1
% 
%       longPathName = getLongPath(shortPathName)
% 
%       longPathName =
% 
%       a b c d e f g h i j
%
%  See also getShortPath.

%  Copyright 2015, Jerome Briot