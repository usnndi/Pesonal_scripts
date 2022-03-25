Import-Csv "C:\Users\jloveall\ASK\Project Services Group - Working Data\NORTHSTAR\OneDrive Migration\Import\folders.csv" | ForEach-Object {
New-Item -Path "C:\Users\jloveall\NorthStar Cooperative\Web Documents - Employee Records\Administrative Group\Research\" -Name $_.Subfolder -ItemType "directory"
}