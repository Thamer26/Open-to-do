require 'spec_helper'

describe "todo", type: :feature, js: true do
  before :each do
    start_api_server
  end

  it "login" do
    `bin/todo login testuser secret 127.0.0.1:3003 -c todo.test`
    expect(YAML::load_file("todo.test")).to eql( username: 'testuser', password: 'secret', host: '127.0.0.1:3003' )
  end

  it "whoami" do
    result = `bin/todo whoami -c todo.test`
    expect(result.strip).to eql "1: testuser"
  end

  it "users" do
    User.create( username: "user2", password: "password" )
    result = `bin/todo users -c todo.test`
    expect(result).to eql( 
%Q{1: testuser
2: user2
})
  end

  it "create_user" do
    result = `bin/todo create_user myname secret -c todo.test`
    result = `bin/todo users -c todo.test`
    expect(result).to eql(
%Q{1: testuser
2: myname
})
  end

  it "lists" do
    user = User.first
    user.lists.create name: 'testlist'
    user.lists.create name: 'testlist2'

    result = `bin/todo lists -c todo.test`
    expect(result).to eql(
%Q{testlist
testlist2
})
  end

  it "create_list" do
    user = User.first
    user.lists.create name: 'testlist'
    result = `bin/todo create_list testlist9 -c todo.test`

    result = `bin/todo lists -c todo.test`
    expect(result).to eql(
%Q{testlist
testlist9
})
  end

end