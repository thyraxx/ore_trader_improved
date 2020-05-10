class OreTraderImproved : ScriptWidgetHost
{
    TextWidget@ m_wNgp;
    SpriteButtonWidget@ m_wNgpLeft;
    SpriteButtonWidget@ m_wNgpRight;
    ScalableSpriteButtonWidget@ m_wNgpButtonAmount;
    ScalableSpriteButtonWidget@ m_wNgpButtonMax;
    ScalableSpriteButtonWidget@ m_wNgpButtonChoiceBuy;

    MenuTabSystem@ m_tabSystem;

    float m_oreAmount = 0;

    int m_lastNgp = -1;

    OreTraderImproved(SValue& sval)
    {
        super();
    }

    void Initialize(bool loaded) override
    {
        @m_wNgp = cast<TextWidget>(m_widget.GetWidgetById("ngp"));
        @m_wNgpButtonAmount = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("buyorsell"));
        @m_wNgpButtonMax = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("buy-max"));
        @m_wNgpButtonChoiceBuy = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("choice-buy"));
        m_wNgpButtonChoiceBuy.SetChecked(true);


        @m_wNgpLeft = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ngp-left"));
        @m_wNgpRight = cast<SpriteButtonWidget>(m_widget.GetWidgetById("ngp-right"));

        UpdateNgp();
    }

    float getOreAmount()
    {
        return m_oreAmount;
    }

    int GetHighestAmountOre()
    {
        auto gm = cast<Campaign>(g_gameMode);
        if(m_wNgpButtonChoiceBuy.IsChecked()){
            return (gm.m_townLocal.m_gold / 800);
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

            m_wNgp.SetText("+" + int(m_oreAmount));
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

                m_wNgp.SetText("-" + int(m_oreAmount));
                m_wNgpLeft.m_enabled = (int(m_oreAmount) > 0);
                m_wNgpRight.m_enabled = (int(m_oreAmount) < highestAmountOre);
                m_wNgpButtonAmount.m_enabled = (highestAmountOre > 0 && m_oreAmount != 0);
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
                if((m_oreAmount*800) <= gm.m_townLocal.m_gold){ 
                    gm.m_townLocal.m_ore += m_oreAmount;
                    gm.m_townLocal.m_gold -= (m_oreAmount*800);
                }
            }else{
                if(m_oreAmount <= gm.m_townLocal.m_ore){ 
                    gm.m_townLocal.m_ore -= m_oreAmount;
                    gm.m_townLocal.m_gold += (m_oreAmount*800);
                }
            }

            UpdateNgp();
        }
        else if (name == "buy-max-amount")
        {
            auto gm = cast<Campaign>(g_gameMode);
            gm.m_townLocal.m_ore += GetHighestAmountOre();
            gm.m_townLocal.m_gold -= (GetHighestAmountOre()*800);
            UpdateNgp();
        }
        else
            ScriptWidgetHost::OnFunc(sender, name);
    }
}
