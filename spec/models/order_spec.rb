describe Order do

  context "attributes" do

    [:address_one, :address_two, :city, :country, :number, :state, :status, 
      :token, :transaction_id, :zip, :shipping, :tracking_number, :name, 
      :price, :phone, :expiration
      ].each do |property|
        it { should allow_mass_assignment_of property }   
      end  

      it { should_not allow_mass_assignment_of :uuid }

      it "generates UUID before validation on_create" do
        # TODO
      end

      it { Order.primary_key.should == 'uuid' }

    end

  context "class methods" do

    describe ".prefill!" do

      before do
        @options = {
          name: 'marin',
          user_id: 12983,
          price: 123.12
        }
        @order = Order.prefill!(@options)
      end

      it "sets the name" do
        @order.name.should == @options[:name]
      end

      it "sets user_id" do
        @order.user_id.should == @options[:user_id]
      end

      it "sets the price" do
        @order.price.should == @options[:price]
      end

      it "saves" do
        Order.any_instance.should_receive :save!
        Order.prefill!(@options)
      end

      it "uses the right order number" do
        numbah = Order.next_order_number
        Order.prefill!(@options).number.should == numbah
      end

    end

    describe ".postfill!" do
      fixtures :orders

      before do
        @options = {
          callerReference: 'ec781fa2-c5e6-4af9-8049-4dee15a85296',
          tokenID: 128736127863,
          addressLine1: '102 Fake address',
          addressLine2: 'Apt 12, 3rd fl',
          city: 'Mountain View',
          state: 'CA',
          status: 'IN PROGRESS',
          zip: '94041',
          phoneNumber: '650 219 9382',
          country: 'United States',
          expiry: (Time.now + 99999).to_s
        }

        Order.stub!(:find_by_uuid!).and_return orders(:one)
        @order = Order.postfill!(@options)
      end

      it "finds order by uuid" do
        Order.should_receive(:find_by_uuid!)
        Order.postfill!
      end

      it "sets the token" do
        @order.token.should == @options[:tokenID]
      end

      it "checks if token is present" do
        Order.postfill!.should be_nil
      end

      it "sets addresses" do
        @order.address_one.should == @options[:addressLine1]
        @order.address_two.should == @options[:addressLine2]
      end

      it "sets city" do
        @order.city.should == @options[:city]
      end

      it "sets state" do
        @order.state.should == @options[:state]
      end

      it "sets status" do
        @order.status.should == @options[:status]
      end

      it "sets zip" do
        @order.zip.should == @options[:zip]
      end

      it "sets country" do
        @order.country.should == @options[:country]
      end

      it "sets phone" do
        @order.phone.should == @options[:phoneNumber]
      end

      it "sets expiration" do
        @order.expiration.should == Date.parse(@options[:expiry])
      end

      it "saves" do
        Order.any_instance.should_receive :save!
        Order.postfill!(@options)
      end

    end

  end


  describe "validators" do

    it { should validate_presence_of :name }
    it { should validate_presence_of :price }
    it { should validate_presence_of :user_id }

  end

end