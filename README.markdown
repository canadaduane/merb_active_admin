Merb ActiveAdmin
================

## Synopsis ##

Merb ActiveAdmin is a drop-in backend for your Merb applications that use the Sequel ORM [1].  It gives application administrators direct access to specified models so they can add, edit or delete anything they need to.  It also provides a way to add or remove associated data, e.g. one-to-many, or many-to-many relationships between models.  These plugin features are provided with very low configuration so that setting it up is as easy as possible.

## Installation ##

Three steps:
1. Download
2. Install
3. Include ActiveAdmin

As with all Merb gem plugins, you can install merb_active_admin in either your system gem repository or your application's gem repository.  Here's an example of downloading and installing it in your app's gems folder:

    $ wget http://github.com/canadaduane/merb_active_admin/tree/master/pkg/merb_active_admin-0.3.gem?raw=true
    $ cd my_merb_app
    $ mkdir gems
    $ gem install ../merb_active_admin-0.3.gem -l -i ./gems

Now on to step 3: Add the line "include ActiveAdmin" to each of the Sequel models that you want available in ActiveAdmin.  For example, here is an example from app/models/assignment.rb:

    class Assignment < Sequel::Model(:assignments)
      include ActiveAdmin
      set_schema do
        integer :id, :primary_key => true, :auto_increment => true
        string  :name, :unique => true, :null => false
        string  :link
        text    :instructions
      end
  
      one_to_many :submissions
    end

    Assignment.create_table unless Assignment.table_exists?

Run the app, and visit your new admin area at:

    http://localhost:4000/active_admin/

## Source Code ##
 
Main repository is at [http://github.com/canadaduane/merb_active_admin/tree](http://github.com/canadaduane/merb_active_admin/tree)


## From the Screencast ##

"Here's ActiveAdmin.  You can browse all of the data in your models.  When you click on a particular piece of data, you can see associated data for that row.  I've used jQuery and Flexigrid to provide the flexible tables and pagination.  As you can see, one-to-many, many-to-one and many-to-many relationships are handled automatically.  You can add and remove associations between models.  Your app's routes are automatically adjusted by the plugin so that you can drop in the ActiveAdmin plugin and have it just work.  There are some configuration options that make customizing it easy once you have it up and running."



[1] Sequel is an ORM that makes proper use of datasets for query manipulation all while using Ruby code to drive the underlying SQL.  When you add the sequel-model layer to sequel, what you get is something very similar to ActiveRecord, but with the much more powerful dataset abstraction underneath.

http://code.google.com/p/ruby-sequel/