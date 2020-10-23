fname = "ET-2020223--10-deg-15.5-o2.csv";
%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["labels", "values"];
opts.VariableTypes = ["string", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "labels", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "labels", "EmptyFieldRule", "auto");

% Import the data
tbl = readtable(fname, opts);

%% Convert to output type
labels = tbl.labels;
values = tbl.values;

%% Clear temporary variables
clear opts tbl

temp.one.ET2020223 = values(strcmp(labels, 'Temp1') == 1);
temp.two.ET2020223 = values(strcmp(labels, 'Temp2') == 1);
time.one.ET2020223 = values(strcmp(labels, 'Time1') == 1);
time.two.ET2020223 = values(strcmp(labels, 'Time2') == 1);