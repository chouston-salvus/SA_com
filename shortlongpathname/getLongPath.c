/******************************************************************************************
 * MATLAB C-MEX file that converts the specified path to its long form on Windows.        *
 *                                                                                        *
 * To compile the file with MATLAB :                                                     *
 *   mex GetLongPathName.c                                                                *
 *                                                                                        *
 * See the MSDN website:                                                                  *
 *   http://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx   *
 *   http://msdn.microsoft.com/en-us/library/windows/desktop/aa364989%28v=vs.85%29.aspx   *
 *                                                                                        *
 * Author: Jerome Briot                                                                   *
 *    http://briot-jerome.developpez.com/                                                 *
 *    http://www.mathworks.com/matlabcentral/fileexchange/authors/21984                   *
 * Contact: dutmatlab at yahoo dot fr                                                     *
 *                                                                                        *
 * Copyright 2015, Jerome Briot                                                           *
******************************************************************************************/

#include "mex.h"
#include <windows.h>

void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] ) {
    
    mwSize buflen;
    DWORD errCode;
	int status;
    LPTSTR err = NULL;
	LPTSTR buf = NULL;
    TCHAR* in = NULL;

    if (nrhs != 1)
	    mexErrMsgIdAndTxt( "GetLongPathName:invalidNumInputs", 
                "One input argument required.");

    if (nlhs > 1)
	    mexErrMsgIdAndTxt( "GetLongPathName:maxlhs",
                "Too many output arguments.");    

    if (!mxIsChar(prhs[0]) || (mxGetM(prhs[0]) != 1 ) )
	    mexErrMsgIdAndTxt( "GetLongPathName:invalidInput", 
                "Input argument must be a string.");
    
    if (mxGetN(prhs[0]) > MAX_PATH)  {
        err = mxMalloc(200);
        sprintf(err, "Path name too long (%d characters max.)", MAX_PATH);
	    mexErrMsgIdAndTxt( "GetShortPathName:tooManyCharInPath", err);
    }
    
    buflen = mxGetN(prhs[0])*sizeof(mxChar)+1;
    
    in = mxMalloc(buflen);
    
    status = mxGetString(prhs[0], in, buflen);
    
    if (status)
        mexErrMsgIdAndTxt( "GetShortPathName:cannotGetString", 
                "Unable to copy the input string");
    
    buflen = GetLongPathName(in, NULL, 0);
    
    if (buflen == 0) {
        errCode = GetLastError();
        FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
                NULL, errCode, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                (LPTSTR) &err, 0, NULL);
        mexErrMsgIdAndTxt( "GetLongPathName:GetLongPathNameFailed", err);
    }
    
    buf = mxMalloc(sizeof(TCHAR) * buflen);
    
    buflen = GetLongPathName(in, buf, (DWORD)buflen);
    
    if (buflen == 0) {
        errCode = GetLastError();
        FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
                NULL, errCode, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                (LPTSTR) &err, 0, NULL);
        mexErrMsgIdAndTxt( "GetLongPathName:GetLongPathNameFailed", err);
    }
    
    plhs[0] = mxCreateString(buf);
    
    mxFree(buf);
    
}
