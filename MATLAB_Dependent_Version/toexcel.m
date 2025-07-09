% Assuming you have already imported data and performed your manipulations
% Get the active Excel application
ExcelApp = actxGetRunningServer('Excel.Application');
% Get the active workbook and active sheet
ActiveWorkbook = ExcelApp.ActiveWorkbook;
ActiveSheet = ExcelApp.ActiveSheet;
% Convert your manipulated data (e.g., a MATLAB matrix or cell array) to a table
% Assuming your data is stored in a variable called 'manipulatedData'
% load patients.mat
% Tdata = table(LastName,Age,Weight,Smoker);
% 
% dataTable = table(Tdata);
% % Get the size of the data table
% [numRows, numCols] = size(Tdata);

% Get the range of cells to write to (assuming you want to start at cell A1)
%range = ExcelApp.ActiveSheet.Range(['A1:', ExcelApp.ActiveCell.Offset(numRows-1, numCols-1).Address]);
%range = ExcelApp.ActiveSheet.Range('A1:D100');
% Write the data to the active sheet
ExcelApp.ActiveSheet.Range('A1:A10').Value = [1:10];
% Save and close the workbook (optional, if you want to save the changes)
ActiveWorkbook.Save;
%ActiveWorkbook.Close;
% Quit Excel application (optional, if you want to close Excel)
%ExcelApp.Quit;