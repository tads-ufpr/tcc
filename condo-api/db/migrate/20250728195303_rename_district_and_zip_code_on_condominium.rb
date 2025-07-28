class RenameDistrictAndZipCodeOnCondominium < ActiveRecord::Migration[8.0]
  def change
    rename_column :condominia, :district, :neighborhood
    rename_column :condominia, :zip_code, :zipcode
  end
end
