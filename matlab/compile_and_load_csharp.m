function asm = compile_and_load_csharp(src,refs,dll)
% compile_and_load_csharp(src,dll): Compile C# code to a DLL and load it
%  src: Cell-array of C# file names to include, relative or absolute file names.
%       A single file can be specified as a string rather than cell-array.
%  refs: A string or cell-array specifying which system assemplies to
%       reference in the compilation.
%  dll: File name of the generated DLL. If ommitted, use the base name of
%       the first C# source file.
% (c) Svein Brekke, April 2020. Free to use for any purpose as long as this line is preserved.
    if ischar(src)
        src = {src};
    end
    if nargin<2
        refs = {};
    elseif ischar(refs)
        refs = {refs};
    end            
    if nargin<3
        dll = [src{1}(1:end-3) '.dll'];
    end
    fld = fileparts(dll);
    if isempty(fld)
        fld = [fileparts(fullfile(dll)),'\'];
    end
    compile(src,refs,dll);
    if ~isfile(dll)
        error(['Failed to generate ',dll])
    end
    if nargout > 0
        asm = addAssemblyFromFolder(dll,fld);
    else
        addAssemblyFromFolder(dll,fld);
    end
end

function compile(src,refs,dll)
    framework = 'c:/Windows/Microsoft.NET/Framework64/v4.0.30319';
    ref = '';
    for R=refs
        ref = [ref,' /reference:"',strrep(framework,'/','\'),'\',R{1},'.dll"']; %#ok<AGROW>
    end
    cmd = [framework,'/csc.exe /nologo /target:library ',ref,' /out:',dll];
    for F = src
       cmd = [cmd,' ',strrep(F{1},'/','\')]; %#ok<AGROW>
    end
    fprintf('Compiling %s ...', dll);
    %fprintf([strrep(cmd,'\','\\'),'\n'])
    [result,output] = system(cmd);
    if result~=0
        fprintf(2,['\n',strrep(output,'\','\\')]);
    else
        fprintf(' done!\n');
    end
end

function asm = addAssemblyFromFolder(dll, fld)
    if ~contains(getenv('PATH'),[fld,';'])
        setenv('PATH',[fld,';',getenv('PATH')])
    end
    try
        asm = NET.addAssembly(dll);
    catch ex
        error(['Failed to load ',dll,', got loader exception "',e.ExceptionObject.LoaderExceptions.Get(0).Message,'"'])
    end
end
