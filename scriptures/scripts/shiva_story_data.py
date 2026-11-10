"""Story briefs for scriptures/shiva: one short plain-English brief per story slug.

The briefs are my own summaries of the widely told stories. Where the Thiruppugazh uses a Tamil local detail
that is not in the Sanskrit texts, the brief says so. Verse-level references are not here: they come from
refs-sanskrit.json, refs-saints.json and tirumurai-deeds.json (see deity_shiva.py).
"""

S = {}


def story(slug, title, brief):
    S[slug] = dict(title=title, brief=brief)


# ------------------------------------------------------------ deeds of Shiva
story("shiva-tripura", "Burning of the three cities (Tripura)",
      "Three flying cities of the demons Tarakaksha, Kamalaksha and Vidyunmali made them unconquerable. The gods made Shiva a "
      "chariot: Meru the bow, Vishnu the arrow, Vasuki the string. When the cities aligned he destroyed them with one smile or "
      "arrow. A Tamil tradition has Ganesha breaking the chariot's axle before the battle (song 1).")
story("shiva-kama", "Kama burned by the forehead eye",
      "The gods sent Kama, god of love, to break Shiva's meditation so that he would marry Parvati and father a commander "
      "for their army. Shiva opened his forehead eye and burned Kama to ash; Rati's grief won Kama a bodiless life (Ananga).")
story("shiva-poison", "Shiva drinks the Halahala poison",
      "When the gods and demons churned the milk ocean, the Halahala poison rose and threatened the worlds. Shiva drank it "
      "at the gods' plea; Parvati held his throat and the poison stayed there, turning it blue (Neelakantha).")
story("shiva-daksha", "Destruction of Daksha's sacrifice",
      "Daksha insulted Shiva and held a sacrifice to which Shiva was not invited. His daughter Sati died there. Shiva sent "
      "Virabhadra, who wrecked the sacrifice and cut off Daksha's head; Daksha was later revived with a goat's head.")
story("shiva-yama", "Shiva kicks Yama (Markandeya)",
      "The boy sage Markandeya, fated to die at sixteen, held the Shiva linga. Yama threw his noose and it fell around the "
      "linga as well. Shiva came out of it, kicked Yama down (Kalantaka, Kalasamharamurti) and gave Markandeya lasting youth.")
story("shiva-brahma-head", "Brahma's fifth head cut off",
      "Brahma's fifth head spoke proudly, or the head claimed equality with Shiva. Shiva, as Bhairava, cut it off with his "
      "fingernail; the skull stuck to his hand as a begging bowl and he was driven to wander until it fell away.")
story("shiva-bhikshatana", "Shiva as the wandering beggar (Bhikshatana)",
      "Carrying the skull bowl, Shiva wandered naked through the Daruka forest asking for alms, bewitching the sages' wives "
      "and breaking the sages' pride in rites. Vishnu appears as Mohini beside him in the story.")
story("shiva-annamalai", "The fire pillar: Vishnu and Brahma fail to find his ends",
      "Vishnu and Brahma quarrelled over who was greater. Shiva stood between them as an endless column of fire. Vishnu "
      "as a boar dug down and Brahma as a swan flew up; Vishnu confessed he could not reach the foot, Brahma falsely "
      "claimed the crown. The fire is worshipped at Arunachala (Tiruvannamalai).")
story("shiva-ganga", "Ganga caught in Shiva's matted hair",
      "Bhagiratha prayed for Ganga to come down and free his ancestors. The river's fall would have broken the earth, so "
      "Shiva received her in his matted locks and let her flow out gently.")
story("shiva-ravana", "Ravana lifts Kailasa",
      "Ravana tried to lift Mount Kailasa. Shiva pressed it down with his toe and crushed Ravana's arms. After a long cry "
      "and hymns Ravana was released; the name Ravana is explained as 'the one who roared'.")
story("shiva-sarabha", "Shiva as Sarabha subdues Narasimha",
      "After Narasimha killed Hiranyakashipu his rage did not cool. Shiva took the form of the fierce Sarabha (part lion, "
      "part bird) and calmed him. The story is told in later Puranas and Shaiva tradition.")

# ------------------------------------------------------------ forms and dance
story("shiva-nataraja", "Shiva as the dancer (Nataraja)",
      "Shiva dances: the Ananda Tandava in the golden hall at Chidambaram (Thillai), the contest with Kali at "
      "Tiruvalangadu, the dance in the burning ground, with his foot on the dwarf Muyalakan. Vishnu, Brahma and the "
      "serpent Adisesha watch.")
story("shiva-ardhanari", "Ardhanari: half of him is Uma",
      "Shiva shares half his body with Parvati (Ardhanarishvara). At Kanchi, Kamakshi's penance wins her the left half of "
      "Ekambareshwara; the Thiruppugazh often marks Murugan as son of the Lord with Uma at his left.")
story("shiva-dakshinamurti", "Dakshinamurti, the silent teacher",
      "Shiva sits facing south under a banyan tree and teaches the sages Sanaka and his brothers by silence alone.")

# ------------------------------------------------------------ saints and temple stories
story("shiva-sambandar", "Sambandar and the Jains of Madurai",
      "The child saint Sambandar of Sirkazhi, nursed with Uma's milk, went to Madurai, healed the Pandya's fever with holy "
      "ash and defeated the Jains in debate and contests (a fire test, a palm-leaf floating against the Vaigai). "
      "Tradition says the Jains were then impaled on the stake; the Thiruppugazh often adds this.")
story("shiva-tiruvilaiyadal", "The sacred sports of Shiva at Madurai",
      "Shiva as Sokkanathar and Meenakshi's consort works sixty-four wonders at Madurai, such as turning jackals into "
      "horses, carrying earth for the Vaigai bank and being struck by the king's cane, and arbitrating the poet "
      "Nakkeerar's dispute.")
story("shiva-nayanmar", "Saints of the Tamil Shaiva tradition",
      "Songs naming Appar, Sundarar (for whom Shiva went as messenger to his wife Paravai), Manikkavasagar (for whom "
      "Shiva turned jackals into horses) or Kachchiyappar.")
story("shiva-kurundam", "Manikkavasagar under the kurundam tree",
      "The Pandya's minister Manikkavasagar went to buy horses and met Shiva as a guru under the kurundam tree at "
      "Tiruperunthurai. He gave the money to the temple and his life to Shiva.")

# ------------------------------------------------------------ Murugan and Shiva
story("shiva-pranava", "Murugan teaches Shiva the Pranava",
      "Brahma could not explain the meaning of Om, so Murugan imprisoned him. When Shiva asked for the release, Murugan "
      "told him the meaning of Om in his ear. The Kanda Puranam (Utpatti Kandam, vv. 1213-1265) sets this on Mount Skanda; later Tamil tradition "
      "places it at Swamimalai (Swaminatha). The Thiruppugazh repeats this many times.")
story("shiva-skanda-birth", "Murugan born from Shiva's eye",
      "Six sparks from Shiva's forehead eye were carried by Agni (and Vayu) to the Ganga, which bore them to the Saravana pool and became six babies, "
      "nursed by the six Krittikas. Uma joined them into one six-faced child.")
