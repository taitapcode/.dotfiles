{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.app.libreoffice;
in
{
  options.modules.home.app.libreoffice.enable =
    lib.mkEnableOption "LibreOffice with Microsoft Office-like UI and defaults";

  config = lib.mkIf cfg.enable {
    programs.libreoffice = {
      enable = true;
      package = pkgs.libreoffice;
      settings = {
        # Giao diện kiểu Office: ribbon (Tabbed), icon Colibre tối, tiếng Anh.
        "/org.openoffice.Office.Common/Misc" = {
          SymbolStyle = "colibre_dark";
          ShowTipOfTheDay = false;
          FirstRun = false;
        };
        "/org.openoffice.Setup/L10N" = {
          ooLocale = "en-US";
        };

        # Lưu mặc định sang định dạng MS Office, tắt cảnh báo định dạng lạ.
        "/org.openoffice.Office.Common/Save/Document" = {
          WarnAlienFormat = false;
          AutoSave = true;
          AutoSaveTimeIntervall = 10;
        };

        "/org.openoffice.Office.UI.ToolbarMode" = {
          ActiveWriter = "notebookbar.ui";
          ActiveCalc = "notebookbar.ui";
          ActiveImpress = "notebookbar.ui";
          ActiveDraw = "notebookbar.ui";
        };
        "/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Writer']" =
          {
            Active = "notebookbar.ui";
          };
        "/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Calc']" =
          {
            Active = "notebookbar.ui";
          };
        "/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Impress']" =
          {
            Active = "notebookbar.ui";
          };
        "/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Draw']" =
          {
            Active = "notebookbar.ui";
          };
        # Ribbon Tabbed vẫn hiện menu bar kiểu Office.
        "/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Writer']/Modes/org.openoffice.Office.UI.ToolbarMode:ModeEntry['Tabbed']" =
          {
            HasMenubar = true;
          };
        "/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Calc']/Modes/org.openoffice.Office.UI.ToolbarMode:ModeEntry['Tabbed']" =
          {
            HasMenubar = true;
          };
        "/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Impress']/Modes/org.openoffice.Office.UI.ToolbarMode:ModeEntry['Tabbed']" =
          {
            HasMenubar = true;
          };
        "/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Draw']/Modes/org.openoffice.Office.UI.ToolbarMode:ModeEntry['Tabbed']" =
          {
            HasMenubar = true;
          };

        # Impress: mở presentation mới vào thẳng trang trắng, không hỏi template.
        "/org.openoffice.Office.Impress/Misc/NewDoc" = {
          AutoPilot = false;
        };

        "/org.openoffice.Setup/Office/Factories/org.openoffice.Setup:Factory['com.sun.star.text.TextDocument']" =
          {
            ooSetupFactoryDefaultFilter = "MS Word 2007 XML";
          };
        "/org.openoffice.Setup/Office/Factories/org.openoffice.Setup:Factory['com.sun.star.sheet.SpreadsheetDocument']" =
          {
            ooSetupFactoryDefaultFilter = "Calc MS Excel 2007 XML";
          };
        "/org.openoffice.Setup/Office/Factories/org.openoffice.Setup:Factory['com.sun.star.presentation.PresentationDocument']" =
          {
            ooSetupFactoryDefaultFilter = "Impress MS PowerPoint 2007 XML";
          };

        # Giữ font mặc định hiện tại cho văn bản học thuật (không phải Calibri).
        # KHÔNG set các key *Height: chúng tính bằng 1/100 mm (12pt = 423), để trống
        # thì LO dùng cỡ mặc định 12pt và vẫn giữ Heading 14pt.
        "/org.openoffice.Office.Writer/DefaultFont" = {
          Standard = "Times New Roman";
          Heading = "Times New Roman";
          List = "Times New Roman";
          Caption = "Times New Roman";
          Index = "Times New Roman";
        };
      };
    };
  };
}
