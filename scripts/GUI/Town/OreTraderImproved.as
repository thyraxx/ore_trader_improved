class OreTraderImproved : ScriptWidgetHost
{
    TextWidget@ m_wNgp;
    SpriteButtonWidget@ m_wNgpLeft;
    SpriteButtonWidget@ m_wNgpRight;
    ScalableSpriteButtonWidget@ m_wNgpButtonAmount;
    ScalableSpriteButtonWidget@ m_wNgpButtonMax;
    ScalableSpriteButtonWidget@ m_wNgpButtonChoiceBuy;

    MenuTabSystem@ m_tabSystem;

    // TODO: better naming convention
    float m_oreAmount = 0;

    int m_lastNgp = -1;

    int buyOreCost;
    int sellOreCost;

    int shopLevel;

    Upgrades::UpgradeShop@ m_shop;

    OreTraderImproved(SValue& sval)
    {
        super();
    }

    void Initialize(bool loaded) override
    {
        GetShopLevel();
        SetCostPerOre(shopLevel);

        @m_wNgp = cast<TextWidget>(m_widget.GetWidgetById("ngp"));
        @m_wNgpButtonAmount = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("buyorsell"));
        @m_wNgpButtonMax = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("buy-max"));
        @m_wNgpButtonChoiceBuy = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("choice-buy"));
        m_wNgpButtonChoiceBuy.SetChecked(true);


        @m_wNgpLeft = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ngp-left"));
        @m_wNgpRight = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ngp-right"));

        UpdateNgp();
    }

    void GetShopLevel(){
        auto record = GetLocalPlayerRecord();
        @m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop("townhall"));
        
        for(uint i = 0; i < m_shop.m_upgrades.length(); i++)
        {
            // Debugging purposes
            //print(m_shop.m_upgrades[i].m_id + " : " + (m_shop.m_upgrades[i].m_id == "oretrader"));
            
            // Finding the oretrader and returning the highest upgraded level
            // not the best solution? But works for now
            if(m_shop.m_upgrades[i].m_id == "oretrader"){
                for(uint k = 0; k < m_shop.m_upgrades[i].m_steps.length(); k++){
                    if(m_shop.m_upgrades[i].m_steps[k].IsOwned(record)){
                        shopLevel = m_shop.m_upgrades[i].m_steps[k].m_level;
                    }
                    //Debugging purposes
                    //print(m_shop.m_upgrades[i].m_steps[k].m_level + " : " + m_shop.m_upgrades[i].m_steps[k].IsOwned(record));
                }
                break;
            }
            
        }
    }

    // TODO: Lookup shoplevel and set ore price, 
    // maybe use vec2/array to return it in 1 variable instead?
    void SetCostPerOre(int shopLevel){
        switch(shopLevel)
        {
            case 1:
                buyOreCost = 1500;
                sellOreCost = 200;
                break;
            case 2:
                buyOreCost = 1250;
                sellOreCost = 350;
                break;
            case 3:
                buyOreCost = 1000;
                sellOreCost = 500;
                break;
            case 4:
                buyOreCost = 800;
                sellOreCost = 700;
                break;
        }
    }

    float getOreAmount()
    {
        return m_oreAmount;
    }

    int GetHighestAmountOre()
    {
        auto gm = cast<Campaign>(g_gameMode);
        if(m_wNgpButtonChoiceBuy.IsChecked()){
            return (gm.m_townLocal.m_gold / buyOreCost);
        }else{
            return gm.m_townLocal.m_ore;
        }
    }

    void SetNgp(float ngp)
    {
        m_oreAmount = ngp;
    }

    void UpdateNgp()
    {
        auto gm = cast<Campaign>(g_gameMode);

        if(m_wNgpButtonChoiceBuy.IsChecked())
        {
            
            float m_oreAmount = getOreAmount();
            int highestAmountOre = GetHighestAmountOre();

            if (m_oreAmount > highestAmountOre)
            {
                m_oreAmount = highestAmountOre;
                SetNgp(m_oreAmount);
            }

            m_wNgp.SetText(int(m_oreAmount));
            m_wNgpLeft.m_enabled = (int(m_oreAmount) > 0);
            m_wNgpRight.m_enabled = (int(m_oreAmount) < highestAmountOre);
            m_wNgpButtonAmount.m_enabled = (GetHighestAmountOre() > 0 && m_oreAmount != 0);
            
            }else{
                float m_oreAmount =  getOreAmount();
                int highestAmountOre = gm.m_townLocal.m_ore;

                if (m_oreAmount > highestAmountOre)
                {
                    m_oreAmount = highestAmountOre;
                    SetNgp(m_oreAmount);
                }

                m_wNgp.SetText(int(m_oreAmount));
                m_wNgpLeft.m_enabled = (int(m_oreAmount) > 0);
                m_wNgpRight.m_enabled = (int(m_oreAmount) < highestAmountOre);
                m_wNgpButtonAmount.m_enabled = (highestAmountOre > 0 && m_oreAmount != 0);
                
                // TODO: Change ui so there isn't a empty area
                // after removing the button
                //m_wNgpButtonMax.Remove();
            }

        m_wNgpButtonMax.m_enabled = (m_wNgpButtonChoiceBuy.IsChecked() && GetHighestAmountOre() > 0);
        DoLayout();
    }

    bool ShouldFreezeControls() override { return true; }
    bool ShouldDisplayCursor() override { return true; }
    bool ShouldSaveExistance() override { return false; }

    void Update(int dt) override
    {
        if(m_wNgpButtonChoiceBuy.IsChecked()){
            float ngp = getOreAmount();

            if (m_lastNgp != int(ngp))
            {
                m_lastNgp = int(ngp);
            }
        }else{
            auto gm = cast<Campaign>(g_gameMode);

            float ngp = gm.m_townLocal.m_ore;
            if (m_lastNgp != int(ngp))
            {
                m_lastNgp = int(ngp);
            }
        }

        UpdateNgp();
        ScriptWidgetHost::Update(dt);
    }

    // TODO: cleanup buy-amount
    void OnFunc(Widget@ sender, string name) override
    {
        bool choiceBuy = (m_wNgpButtonChoiceBuy.IsChecked());
        if (name == "close")
            Stop();
        else if(name == "sell"){
            m_wNgpButtonAmount.SetText("Sell");

            UpdateNgp();
        }
        else if(name == "buy"){
            m_wNgpButtonAmount.SetText("Buy");
            UpdateNgp();
        }

        else if (name == "ngp-prev")
        {
            float ngp = getOreAmount();

            ngp = int(ngp) - 1;
            if (ngp < 0)
                ngp = 0;

            SetNgp(ngp);
            UpdateNgp();
        }
        else if (name == "ngp-next")
        {
            if(choiceBuy){
                float ngp = getOreAmount();

                ngp = int(ngp) + 1;

                int highestNgp = GetHighestAmountOre();
                if (int(ngp) > highestNgp)
                    ngp = int(highestNgp);

                SetNgp(ngp);
                UpdateNgp();
            }else{
                auto gm = cast<Campaign>(g_gameMode);
                float ngp = getOreAmount();

                ngp = int(ngp) + 1;

                int highestNgp = gm.m_townLocal.m_ore;
                if (int(ngp) > highestNgp)
                    ngp = int(highestNgp);

                SetNgp(ngp);
                UpdateNgp();
            }
        }
        else if (name == "buy-amount"){
            auto gm = cast<Campaign>(g_gameMode);
            if(choiceBuy){
                if((m_oreAmount * buyOreCost) <= gm.m_townLocal.m_gold){ 
                    gm.m_townLocal.m_ore += m_oreAmount;
                    gm.m_townLocal.m_gold -= (m_oreAmount * buyOreCost);
                }
            }else{
                if(m_oreAmount <= gm.m_townLocal.m_ore){ 
                    gm.m_townLocal.m_ore -= m_oreAmount;
                    gm.m_townLocal.m_gold += (m_oreAmount * sellOreCost);
                }
            }

            UpdateNgp();
        }
        else if (name == "buy-max-amount")
        {
            auto gm = cast<Campaign>(g_gameMode);
            gm.m_townLocal.m_ore += GetHighestAmountOre();
            gm.m_townLocal.m_gold -= (GetHighestAmountOre() * buyOreCost);
            UpdateNgp();
        }
        else
            ScriptWidgetHost::OnFunc(sender, name);
    }
}
