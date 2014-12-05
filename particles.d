module daring.particles;

import std.random;
import std.stdio;
import std.string;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import animation;

struct ParticleSystem
{
	float initialXVelocity = 0;
	float initialYVelocity = 0;
	float xRandom = 0;
	float yRandom = 0;
	float xForce = 0;
	float yForce = 0;
	float velocityDecay;
	float sourceXRandom = 0;
	float sourceYRandom = 0;
	ubyte alphaDecay;
	ubyte initialAlpha;
	float[] xCoords;
	float[] yCoords;
	float[] xVels;
	float[] yVels;
	int[] alphas;
	SDL_Texture* texture;
	SDL_Rect[] slices;
	SDL_Point origin;
	int initialized;


	void update()
	{
		if (initialized < xCoords.length - 1)
		{
			initialized++;
			alphas[initialized] = initialAlpha;
		}


		xVels[] += xForce;
		yVels[] += yForce;
		xCoords[0..initialized] = xCoords[0..initialized] + xVels[0..initialized];
		yCoords[0..initialized] = yCoords[0..initialized] + yVels[0..initialized];
		alphas[] -= alphaDecay;
		foreach (i; 0 .. cast(int) xCoords.length)
			if (alphas[i] <= 0)
				resetParticle(i);
	}

	void draw(SDL_Renderer* renderer, ref const SDL_Rect camera)
	{
		SDL_Rect dstRect;
		foreach (int i; 0 .. cast(int) xCoords.length)
		{
			SDL_Rect* srcRect = &slices[uniform(0, slices.length)];
			dstRect.w = srcRect.w;
			dstRect.h = srcRect.h;
			dstRect.x = cast(int) xCoords[i] - camera.x;
			dstRect.y = cast(int) yCoords[i] - camera.y;

			SDL_SetTextureAlphaMod(texture, cast(ubyte) alphas[i]);
			SDL_RenderCopy(renderer, texture, srcRect, &dstRect);
		}
	}

	void resetParticle(int index)
	{
		alphas[index] = initialAlpha;
		if (sourceXRandom != 0)
			xCoords[index] = origin.x + uniform(-sourceXRandom, sourceXRandom);
		else
			xCoords[index] = origin.x;

		if (sourceYRandom != 0)
			yCoords[index] = origin.y + uniform(-sourceYRandom, sourceYRandom);
		else
			yCoords[index] = origin.y;

		if (xRandom == 0)
			xVels[index] = initialXVelocity;
		else
			xVels[index] = initialXVelocity + uniform(-xRandom, xRandom);

		if (yRandom == 0)
			yVels[index] = initialYVelocity;
		else
			yVels[index] = initialYVelocity + uniform(-yRandom, yRandom);
	}


	void initialize(int particleCount)
	{
		xCoords.length = particleCount;
		yCoords.length = particleCount;
		alphas.length = particleCount;
		xVels.length = particleCount;
		yVels.length = particleCount;
		foreach (i; 0 .. particleCount)
		{
			resetParticle(i);
		}
	}

}
