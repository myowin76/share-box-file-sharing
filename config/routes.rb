Sharebox::Application.routes.draw do
  
  #for sharing the folders
  match "home/share" => "home#share"
  
  #for browsing the folder and its contents
  match "browse/:folder_id" => "home#browse", :as => "browse"
  
  #for creating folders insiide another folder
  match "browse/:folder_id/new_folder" => "folders#new", :as => "new_sub_folder"
  
  #for uploading files to folders
  match "browse/:folder_id/new_file" => "assets#new", :as => "new_sub_file"
  
  #for renaming a folder
  match "browse/:folder_id/rename" => "folders#edit", :as => "rename_folder"
  
  resources :folders

  #this route is for file downloads
  match "assets/get/:id" => "assets#get", :as => "download"
  
  
  
  
  resources :assets
  
  devise_for :users

  root :to => "home#index"
end
