
//Confetti explosions

void shootConfetti(CBlob@ this){
	shootConfetti(this,500,true);
}

void shootConfetti(CBlob@ this,int16 qtt){
	shootConfetti(this,qtt,true);
}

void shootConfetti(CBlob@ this,int16 qtt,bool useSpeed){
	Vec2f vel;
	if(useSpeed){
		for(int i = 0;i < this.getVelocity().getLength()*qtt+XORRandom(500);i++){
			vel = getRandomVelocity(this.getVelocity().getAngleDegrees(), XORRandom(this.getVelocity().getLength()*2.0f) + XORRandom(10), 10.0f);
			vel += getRandomVelocity(0.0f, 5.0f, 360.0f);
			vel.x *= -1;
			castParticle(this,vel);
		}
	} else {
		for(int i = 0;i < qtt+XORRandom(qtt/10);i++){
			vel = getRandomVelocity(0,1.0f, 360.0f);
			castParticle(this,vel);
		}
	}
}

void castParticle(CBlob@ this,Vec2f vel){
	SColor theColor(255,0,0,0);
	int temp = XORRandom(6) + 1;
	switch(temp){
		case(1):
			theColor.setRed(255);
		case(2):
			theColor.setBlue(255);
			break;
		case(3):
			theColor.setGreen(255);
		case(4):
			theColor.setRed(255);
			break;
		case(5):
			theColor.setBlue(255);
		case(6):
			theColor.setGreen(255);
			break;
	}
	ParticleBlood(this.getPosition(), vel, SColor(theColor));
}