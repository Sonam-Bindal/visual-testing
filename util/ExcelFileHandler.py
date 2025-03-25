

import pandas as pd

class ExcelFileHandler:

    def __init__(self):
        self.file_path = None
        self.file_type = None
        self.data = None
        self.sheet_name = 0

    ''' pass the sheet_index(starts with 0), or pass sheet_name'''
    def _read_file(self, file_path, sheet_name_index):
        self.file_path = file_path
        self.sheet_name=sheet_name_index
        self.file_type = file_path.split('.')[-1]
        if self.file_type in ['xls','xlsx']:
            self.data = pd.read_excel(self.file_path, sheet_name=self.sheet_name)
        elif self.file_type in ['csv']:
            self.data = pd.read_csv(self.file_path)
        else:
            raise ValueError("Invalid file type, Only xls, xlsx and csv are files are supported")
        return self.data

    def _write_to_file(self, data, to_file_path):
        if self.file_type in ['xls', 'xlsx']:
            data.to_excel(to_file_path, index=False)
        elif self.file_type == 'csv':
            data.to_csv(to_file_path, index=False)
        else:
            raise ValueError("Invalid file type. Only xls, xlsx and csv files are supported.")

    def get_column_count(self, file_path,sheet_name, row_index):
        if self.data is None:
            self._read_file(file_path, sheet_name)

        row_data = self.data.iloc[int(row_index)]
        return len(row_data)

    def get_row_count(self, file_path, sheet_name):
        if self.data is None:
            self._read_file(file_path, sheet_name)

        return len(self.data)

    ''' row_index, col_index starts with 0'''
    def get_cell_value(self, file_path, sheet_name, row_index, col_index):
        if self.data is None:
            self._read_file(file_path, sheet_name)

        value = self.data.iloc[int(row_index), int(col_index)]
        return "" if pd.isna(value) else value

    ''' row_index, col_index starts with 0'''
    def set_cell_value(self,file_path, sheet_name, row_index, col_index, value):
        if self.data is None:
            self._read_file(file_path, sheet_name)

        self.data.iloc[int(row_index), int(col_index)] = value
        self._write_to_file(self.data,file_path)
