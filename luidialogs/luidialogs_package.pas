{ This file was automatically created by Lazarus. do not edit ! 
  This source is only used to compile and install the package.
 }

unit luidialogs_package; 

interface

uses
    fExportDataset, LuiDialogs, SpreadsheetExport, register_luidialogs, 
  fFrameEditor, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('register_luidialogs', @register_luidialogs.Register); 
end; 

initialization
  RegisterPackage('luidialogs_package', @Register); 
end.