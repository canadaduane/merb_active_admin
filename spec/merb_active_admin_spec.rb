require File.dirname(__FILE__) + '/spec_helper'

require "merb_active_admin/active_admin"

describe "merb_active_admin" do
  it "should load the controller template and do substitutions" do
    ActiveAdmin.action_template.should =~ /class/
    ActiveAdmin.action_template(:controller_class => "Test").should =~ /class Test/
  end
end