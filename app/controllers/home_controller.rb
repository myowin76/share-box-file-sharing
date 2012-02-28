class HomeController < ApplicationController
  

  def index
      if user_signed_in?
          #show folders shared by others
          @being_shared_folders = current_user.shared_folders_by_others
               
               
         #show only root folders (which have no parent folders)
         @folders = current_user.folders.roots 
         
         #show only root files which has no "folder_id"
         @assets = current_user.assets.where("folder_id is NULL").order("uploaded_file_file_name desc")      
      end
   end
   
  #this action is for viewing folders
  def browse
      #first find the current folder within own folders
      @current_folder = current_user.folders.find_by_id(params[:folder_id])  
      @is_this_folder_being_shared = false if @current_folder #just an instance variable to help hiding buttons on View
      
      #if not found in own folders, find it in being_shared_folders
      if @current_folder.nil?
        folder = Folder.find_by_id(params[:folder_id])
        
        @current_folder ||= folder if current_user.has_share_access?(folder)
        @is_this_folder_being_shared = true if @current_folder #just an instance variable to help hiding buttons on View
        
      end
      
      if @current_folder
        #if under a sub folder, we shouldn't see shared folders
        @being_shared_folders = []
        
        #show folders under this current folder
        @folders = @current_folder.children
        
        #show only files under this current folder
        @assets = @current_folder.assets.order("uploaded_file_file_name desc")
        
        render :action => "index"
      else
        flash[:error] = "Don't be cheeky! Mind your own assets!"
        redirect_to root_url
      end
  end
  
  
  #this handles ajax request for inviting others to share folders
  def share    
    #first, we need to separate the emails with the comma
    email_addresses = params[:email_addresses].split(",")

    
    email_addresses.each do |email_address|
      #save the details in the ShareFolder table
      @shared_folder = current_user.shared_folders.new
      @shared_folder.folder_id = params[:folder_id]
      @shared_folder.shared_email = email_address
      
      #getting the shared user id right the owner the email has already signed up with ShareBox
      #if not, the field "shared_user_id" will be left nil for now.
      shared_user = User.find_by_email(email_address)
      @shared_folder.shared_user_id = shared_user.id if shared_user
      
      @shared_folder.message = params[:message]
      @shared_folder.save
      
      #now send email to the recipients
      UserMailer.invitation_to_share(@shared_folder).deliver
    end
    
    #since this action is mainly for ajax (javascript request), we'll respond with js file back (refer to share.js.erb)
    respond_to do |format|
      format.js {
      }
    end
    
  end
end
