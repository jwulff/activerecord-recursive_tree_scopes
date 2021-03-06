require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiverecordRecursiveTreeScopes" do
  describe 'has_ancestors' do
    context 'given a scope name that conflicts' do
      it do
        lambda{ Employee.has_ancestors :ancestors }.should raise_error(ArgumentError, "Employee already responds to ancestors. Please pick another name for has_ancestors scope.")
      end
    end
  end

  describe 'has_descendants' do
    context 'given a scope name that conflicts' do
      it do
        lambda{ Employee.has_descendants :descendants }.should raise_error(ArgumentError, "Employee already responds to descendants. Please pick another name for has_descendants scope.")
      end
    end
  end

  describe 'simple tree' do
    let!(:alonso)  { Employee.create! name: 'Alonso'                    }
    let!(:alfred)  { Employee.create! name: 'Alfred'                    }
    let!(:barry)   { Employee.create! name: 'Barry',   manager: alfred  }
    let!(:bob)     { Employee.create! name: 'Bob',     manager: alfred  }
    let!(:charles) { Employee.create! name: 'Charles', manager: barry   }
    let!(:cameron) { Employee.create! name: 'Cameron', manager: barry   }
    let!(:carl)    { Employee.create! name: 'Carl',    manager: barry   }
    let!(:dave)    { Employee.create! name: 'Dave',    manager: carl    }
    let!(:daryl)   { Employee.create! name: 'Daryl',   manager: charles }
    let!(:dick)    { Employee.create! name: 'Dick',    manager: charles }
    let!(:edward)  { Employee.create! name: 'Edward',  manager: dick    }
    let!(:frank)   { Employee.create! name: 'Frank',   manager: edward  }
    
    describe 'chaining' do
      describe 'ancestors' do
        it do
          frank.managers.where(name: 'Barry').should == [ barry ]
        end
      end
    
      describe 'descendants' do
        it do
          barry.managed.where("name LIKE ?", 'D%').should == [ dave, daryl, dick ]
        end
      end
    end
    
    describe 'Alonso' do
      subject { alonso }
      its(:manager) { should be_nil }
      its(:directly_managed) { should == [] }
      its(:managers) { should == [] }
      its(:managed) { should == [] }
    end
    
    describe 'Alfred' do
      subject { alfred }
      its(:manager) { should be_nil }
      its(:directly_managed) { should == [ barry, bob ] }
      its(:managers) { should == [] }
      its(:managed) { should == [ barry, bob, charles, cameron, carl, dave, daryl, dick, edward, frank ] }
    end
    
    describe 'Barry' do
      subject { barry }
      its(:manager) { should == alfred }
      its(:directly_managed) { should == [ charles, cameron, carl ] }
      its(:managers) { should == [ alfred ] }
      its(:managed) { should == [ charles, cameron, carl, dave, daryl, dick, edward, frank ] }
    end
    
    describe 'Bob' do
      subject { bob }
      its(:manager) { should == alfred }
      its(:directly_managed) { should == [] }
      its(:managers) { should == [ alfred ] }
      its(:managed) { should == [] }
    end
    
    describe 'Charles' do
      subject { charles }
      its(:manager) { should == barry }
      its(:directly_managed) { should == [ daryl, dick ] }
      its(:managers) { should == [ alfred, barry ] }
      its(:managed) { should == [ daryl, dick, edward, frank ] }
    end
    
    describe 'Cameron' do
      subject { cameron }
      its(:manager) { should == barry }
      its(:directly_managed) { should == [] }
      its(:managers) { should == [ alfred, barry ] }
      its(:managed) { should == [] }
    end
    
    describe 'Carl' do
      subject { carl }
      its(:manager) { should == barry }
      its(:directly_managed) { should == [ dave ] }
      its(:managers) { should == [ alfred, barry ] }
      its(:managed) { should == [ dave ] }
    end
    
    describe 'Dave' do
      subject { dave }
      its(:manager) { should == carl }
      its(:directly_managed) { should == [] }
      its(:managers) { should == [ alfred, barry, carl ] }
      its(:managed) { should == [] }
    end
    
    describe 'Daryl' do
      subject { daryl }
      its(:manager) { should == charles }
      its(:directly_managed) { should == [] }
      its(:managers) { should == [ alfred, barry, charles ] }
      its(:managed) { should == [] }
    end
    
    describe 'Dick' do
      subject { dick }
      its(:manager) { should == charles }
      its(:directly_managed) { should == [ edward ] }
      its(:managers) { should == [ alfred, barry, charles ] }
      its(:managed) { should == [ edward, frank ] }
    end
    
    describe 'Edward' do
      subject { edward }
      its(:manager) { should == dick }
      its(:directly_managed) { should == [ frank ] }
      its(:managers) { should == [ alfred, barry, charles, dick ] }
      its(:managed) { should == [ frank ] }
    end
    
    describe 'Frank' do
      subject { frank }
      its(:manager) { should == edward }
      its(:directly_managed) { should == [] }
      its(:managers) { should == [ alfred, barry, charles, dick, edward ] }
      its(:managed) { should == [] }
    end
  end

  describe 'multiple key tree' do
    let!(:george)  { Person.create! name: 'George' }
    let!(:hazel)   { Person.create! name: 'Hazel' }
    let!(:bill)    { Person.create! name: 'Bill', father: george, mother: hazel }
    let!(:william) { Person.create! name: 'William' }
    let!(:sharlyn) { Person.create! name: 'Sharlyn' }
    let!(:tamara)  { Person.create! name: 'Tamara', father: william, mother: sharlyn }
    let!(:john)    { Person.create! name: 'John', father: bill, mother: tamara }
    let!(:mark)    { Person.create! name: 'Mark', father: bill, mother: tamara }
    let!(:buster)  { Person.create! name: 'Buster', father: john }

    describe 'George' do
      subject { george }
      its(:mother) { should be_nil }
      its(:father) { should be_nil }
      its(:progenitors) { should == [] }
      its(:progeny) { should == [ bill, john, mark, buster ] }
    end

    describe 'Hazel' do
      subject { hazel }
      its(:mother) { should be_nil }
      its(:father) { should be_nil }
      its(:progenitors) { should == [] }
      its(:progeny) { should == [ bill, john, mark, buster ] }
    end

    describe 'William' do
      subject { william }
      its(:mother) { should be_nil }
      its(:father) { should be_nil }
      its(:progenitors) { should == [] }
      its(:progeny) { should == [ tamara, john, mark, buster ] }
    end

    describe 'Sharlyn' do
      subject { sharlyn }
      its(:mother) { should be_nil }
      its(:father) { should be_nil }
      its(:progenitors) { should == [] }
      its(:progeny) { should == [ tamara, john, mark, buster ] }
    end

    describe 'Bill' do
      subject { bill }
      its(:mother) { should == hazel }
      its(:father) { should == george }
      its(:progenitors) { should == [ george, hazel ] }
      its(:progeny) { should == [ john, mark, buster ] }
    end

    describe 'Tamara' do
      subject { tamara }
      its(:mother) { should == sharlyn }
      its(:father) { should == william }
      its(:progenitors) { should == [ william, sharlyn ] }
      its(:progeny) { should == [ john, mark, buster ] }
    end

    describe 'John' do
      subject { john }
      its(:mother) { should == tamara }
      its(:father) { should == bill }
      its(:progenitors) { should == [ george, hazel, bill, william, sharlyn, tamara ] }
      its(:progeny) { should == [ buster ] }
    end

    describe 'Mark' do
      subject { mark }
      its(:mother) { should == tamara }
      its(:father) { should == bill }
      its(:progenitors) { should == [ george, hazel, bill, william, sharlyn, tamara ] }
      its(:progeny) { should == [] }
    end

    describe 'Buster' do
      subject { buster }
      its(:mother) { should be_nil }
      its(:father) { should == john }
      its(:progenitors) { should == [ george, hazel, bill, william, sharlyn, tamara, john ] }
      its(:progeny) { should == [] }
    end
  end
end
