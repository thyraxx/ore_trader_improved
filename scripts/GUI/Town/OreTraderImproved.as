class OreTraderImproved : ScriptWidgetHost
{
    TextWidget@ m_wOre;
    TextWidget@ m_orePrice;
    SpriteButtonWidget@ m_wOreLeft;
    SpriteButtonWidget@ m_wOreRight;
    ScalableSpriteButtonWidget@ m_wOreButtonAmount;
    ScalableSpriteButtonWidget@ m_wOreButtonMax;
    ScalableSpriteButtonWidget@ m_wOreButtonChoiceBuy;

    MenuTabSystem@ m_tabSystem;

    // TODO: better naming convention
    int m_oreAmount = 0;

    int m_lastOre = -1;

    int buyOreCost;
    int sellOreCost;

    int shopLevel;

    //
    int m_townGold = 0;
    int m_townOre = 0;

    Upgrades::UpgradeShop@ m_shop;

    OreTraderImproved(SValue& sval)
    {
        super();
    }

    void Initialize(bool loaded) override
    {
        GetShopLevel();
        SetCostPerOre(shopLevel);

        @m_wOre = cast<TextWidget>(m_widget.GetWidgetById("ore"));
        @m_orePrice = cast<TextWidget>(m_widget.GetWidgetById("oreprice"));

        @m_wOreButtonAmount = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("buyorsell"));
        @m_wOreButtonMax = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("buy-max"));
        @m_wOreButtonChoiceBuy = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("choice-buy"));
        @m_wOreButtonChoiceBuy = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("choice-buy"));

        m_wOreButtonChoiceBuy.SetChecked(true);


        @m_wOreLeft = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ore-left"));
        @m_wOreRight = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ore-right"));

        UpdateOre();
    }

    // Set the values for the correct gamemode
    void SetTownGoldAndOre()
    {
        if(!record.mercenary)
        {
            m_townGold = gm.m_townLocal.m_gold;
            m_townOre = gm.m_townLocal.m_ore;
        }else{
            m_townGold = record.mercenaryGold;
            m_townOre = record.mercenaryOre;
        }
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

    int getOreAmount()
    {
        return m_oreAmount;
    }

    int GetHighestAmountOre()
    {
        auto record = GetLocalPlayerRecord();
        auto gm = cast<Campaign>(g_gameMode);

        if(m_wOreButtonChoiceBuy.IsChecked())
        {
            return (m_townGold / buyOreCost);
        }else{
            return m_townOre;
        }
    }

    void SetOreAmount(int Ore)
    {
        m_oreAmount = Ore;
    }

    // TODO: Cleanup and optimize
    void UpdateOre()
    {
        auto record = GetLocalPlayerRecord();
        
        if(!record.mercenary){
            // non merc
            auto gm = cast<Campaign>(g_gameMode);

            if(m_wOreButtonChoiceBuy.IsChecked()){
                
                int m_oreAmount = getOreAmount();
                int highestAmountOre = GetHighestAmountOre();

                if (m_oreAmount > highestAmountOre){
                    m_oreAmount = highestAmountOre;
                    SetOreAmount(m_oreAmount);
                }

                m_orePrice.SetText(buyOreCost);
                m_wOre.SetText(int(m_oreAmount));
                m_wOreLeft.m_enabled = (int(m_oreAmount) > 0);
                m_wOreRight.m_enabled = (int(m_oreAmount) < highestAmountOre);
                m_wOreButtonAmount.m_enabled = (GetHighestAmountOre() > 0 && m_oreAmount != 0);
                
            }else{
                m_orePrice.SetText(sellOreCost);

                int m_oreAmount =  getOreAmount();
                int highestAmountOre = gm.m_townLocal.m_ore;

                if (m_oreAmount > highestAmountOre)
                {
                    m_oreAmount = highestAmountOre;
                    SetOreAmount(m_oreAmount);
                }

                m_wOre.SetText(int(m_oreAmount));
                m_wOreLeft.m_enabled = (int(m_oreAmount) > 0);
                m_wOreRight.m_enabled = (int(m_oreAmount) < highestAmountOre);
                m_wOreButtonAmount.m_enabled = (highestAmountOre > 0 && m_oreAmount != 0);
                
                // TODO: Change ui so there isn't a empty area
                // after removing the button
                //m_wOreButtonMax.Remove();
            }
        }else{
            // merc mode
            if(m_wOreButtonChoiceBuy.IsChecked()){
            
                int m_oreAmount = getOreAmount();
                int highestAmountOre = GetHighestAmountOre();

                if (m_oreAmount > highestAmountOre){
                    m_oreAmount = highestAmountOre;
                    SetOreAmount(m_oreAmount);
                }

                m_orePrice.SetText(buyOreCost);
                m_wOre.SetText(int(m_oreAmount));
                m_wOreLeft.m_enabled = (int(m_oreAmount) > 0);
                m_wOreRight.m_enabled = (int(m_oreAmount) < highestAmountOre);
                m_wOreButtonAmount.m_enabled = (GetHighestAmountOre() > 0 && m_oreAmount != 0);
                
            }else{
                m_orePrice.SetText(sellOreCost);

                int m_oreAmount =  getOreAmount();
                int highestAmountOre = record.mercenaryOre;

                if (m_oreAmount > highestAmountOre){
                    m_oreAmount = highestAmountOre;
                    SetOreAmount(m_oreAmount);
                }

                m_wOre.SetText(int(m_oreAmount));
                m_wOreLeft.m_enabled = (int(m_oreAmount) > 0);
                m_wOreRight.m_enabled = (int(m_oreAmount) < highestAmountOre);
                m_wOreButtonAmount.m_enabled = (highestAmountOre > 0 && m_oreAmount != 0);
                
                // TODO: Change ui so there isn't a empty area
                // after removing the button
                //m_wOreButtonMax.Remove();
            }
        }
        

        m_wOreButtonMax.m_enabled = (m_wOreButtonChoiceBuy.IsChecked() && GetHighestAmountOre() > 0);
        DoLayout();
    }

    bool ShouldFreezeControls() override { return true; }
    bool ShouldDisplayCursor() override { return true; }
    bool ShouldSaveExistance() override { return false; }

    void Update(int dt) override
    {
        if(m_wOreButtonChoiceBuy.IsChecked()){
            int Ore = getOreAmount();

            if (m_lastOre != int(Ore))
            {
                m_lastOre = int(Ore);
            }
        }else{
            auto gm = cast<Campaign>(g_gameMode);

            int Ore = gm.m_townLocal.m_ore;
            if (m_lastOre != int(GetHighestAmountOre())){
                m_lastOre = int(GetHighestAmountOre());
            }
        }

        UpdateOre();
        ScriptWidgetHost::Update(dt);
    }

    // TODO: cleanup
    void OnFunc(Widget@ sender, string name) override
    {
        auto record = GetLocalPlayerRecord();
        bool choiceBuy = (m_wOreButtonChoiceBuy.IsChecked());
        if (name == "close")
            Stop();
        else if(name == "sell"){
            m_wOreButtonAmount.SetText("Sell");

            UpdateOre();
        }
        else if(name == "buy"){
            m_wOreButtonAmount.SetText("Buy");
            UpdateOre();
        }

        else if (name == "ore-prev")
        {
            int Ore = getOreAmount();

            Ore = int(Ore) - 1;
            if (Ore < 0)
                Ore = 0;

            SetOreAmount(Ore);
            UpdateOre();
        }
        else if (name == "ore-next")
        {
            // non merc
            if(choiceBuy){
                int Ore = getOreAmount();

                Ore = int(Ore) + 1;

                int highestOre = GetHighestAmountOre();
                if (int(Ore) > highestOre)
                    Ore = int(highestOre);

                SetOreAmount(Ore);
                UpdateOre();
            }else{
                auto gm = cast<Campaign>(g_gameMode);
                int Ore = getOreAmount();

                Ore = int(Ore) + 1;

                int highestOre = GetHighestAmountOre();
                if (int(Ore) > highestOre)
                    Ore = int(highestOre);

                SetOreAmount(Ore);
                UpdateOre();
            }
        }
        else if (name == "buy-amount"){

            if(!record.mercenary){
                // non merc
                auto gm = cast<Campaign>(g_gameMode);
                if(choiceBuy){
                    if((m_oreAmount * buyOreCost) <= m_townGold){ 
                        m_townOre += m_oreAmount;
                        m_townGold -= (m_oreAmount * buyOreCost);
                    }
                }else{
                    if(m_oreAmount <= m_townOre){ 
                        m_townOre -= m_oreAmount;
                        m_townGold += (m_oreAmount * sellOreCost);
                    }
                }
            }

            UpdateOre();
        }
        else if (name == "buy-max-amount")
        {
            //auto record = GetLocalPlayerRecord();
            if(!record.mercenary){
                // non merc
                auto gm = cast<Campaign>(g_gameMode);
                gm.m_townLocal.m_ore += GetHighestAmountOre();
                gm.m_townLocal.m_gold -= (GetHighestAmountOre() * buyOreCost);
                UpdateOre();
            }else{
                // merc mode
                record.mercenaryOre += GetHighestAmountOre();
                record.mercenaryGold -= (GetHighestAmountOre() * buyOreCost);
                UpdateOre();
            }
        }
        else
            ScriptWidgetHost::OnFunc(sender, name);

    }
}
